import os
import subprocess
import ntpath
import logging
import luigi
import re


def _stem(path):
	return os.path.splitext(ntpath.basename(path))[0]


def _count_frame_log_name(path):
	name = _stem(path)
	return os.path.join(os.path.dirname(__file__), "work_dir\deshake.{0}.stats.log".format(name))


def _windows_path(relative_path, escape_backslash=False):
	relative_path = re.sub('./ps-avisynth-deshake/', '', relative_path)
	relative_path = re.sub('/', r'\\', relative_path)
	name = os.path.join(os.path.dirname(__file__), relative_path)

	if escape_backslash:
		name = re.sub(r'\\', r'\\\\', name)

	return name


class FrameCountAviSynthScript(luigi.Task):
	path = luigi.Parameter()
	logger = logging.getLogger('luigi-interface')

	def output(self):
		return luigi.LocalTarget("./ps-avisynth-deshake/work_dir/deshake.%s.framecount.avs" % _stem(self.path))

	def run(self):
		relative_path = '..\\' + re.sub('/', r'\\', str(self.path))
		log = _count_frame_log_name(self.path)
		content = """A1 = FFAudioSource("{0}")
V1 = FFVideoSource("{0}")
AudioDub(V1, A1).ConvertToRGB32(matrix="PC.709")
WriteFile("{1}", "FrameCount")
""".format(relative_path, log)

		with self.output().open('w') as f:
			f.write(content)


class FrameCountVirtualDubScript(luigi.Task):
	path = luigi.Parameter()

	def requires(self):
		return FrameCountAviSynthScript(self.path)

	def output(self):
		return luigi.LocalTarget("./ps-avisynth-deshake/work_dir/deshake.%s.framecount.script" % _stem(self.path))

	def run(self):
		with self.input().open('rb') as in_file:
			abs_path = _windows_path(in_file.name)
			frame_count_filename = re.sub(r'\\', r'\\\\', abs_path)
			content = """VirtualDub.Open("{0}","",0);
VirtualDub.RunNullVideoPass();
VirtualDub.Close();""".format(frame_count_filename)

			with self.output().open('w') as f:
				f.write(content)


class CountFrames(luigi.Task):
	path = luigi.Parameter()

	def requires(self):
		return FrameCountVirtualDubScript(self.path)

	def output(self):
		return luigi.LocalTarget(_count_frame_log_name(self.path))

	def run(self):
		with self.input().open('rb') as frame_count_virtual_dub_script:
			abs_path = _windows_path(frame_count_virtual_dub_script.name)
			ex = os.path.join(os.path.dirname(__file__), "virtualdub32\\VirtualDub.exe")
			subprocess.run([ex, "/x", "/s", abs_path])


class DeshakeFirstPass(luigi.Task):
	path = luigi.Parameter()

	def requires(self):
		return CountFrames(self.path)

	def output(self):
		return luigi.LocalTarget("./ps-avisynth-deshake/work_dir/deshake.%s.pass1.avs" % _stem(self.path))

	def run(self):
		plugin_name = os.path.join(os.path.dirname(__file__), "Deshaker.vdf")
		name = '..\\' + re.sub('/', r'\\', str(self.path))
		content = """LoadVirtualDubPlugin ("{1}", "deshaker", preroll=0)
A1 = FFAudioSource("{0}")
V1 = FFVideoSource("{0}")
AudioDub(V1, A1).ConvertToRGB32(matrix="PC.709")
Deshaker("19|1|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|0|2|8|30|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|15|1|1|30|30|0|0|1|0|1|1|1|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff")
"""
		# content = re.sub(r'\b\[0\]\b', str(self.path), content)
		content = content.format(name, plugin_name)

		with self.output().open('w') as f:
			f.write(content)


class DeshakeSecondPass(luigi.Task):
	path = luigi.Parameter()

	def requires(self):
		return DeshakeFirstPass(self.path)

	def output(self):
		return luigi.LocalTarget("./ps-avisynth-deshake/work_dir/deshake.%s.pass2.avs" % _stem(self.path))

	def run(self):
		plugin_name = os.path.join(os.path.dirname(__file__), "Deshaker.vdf")
		name = '..\\' + re.sub('/', r'\\', str(self.path))
		content = """SetMemoryMax(500)
LoadVirtualDubPlugin ("{1}", "deshaker", preroll=0)
A1 = FFAudioSource("{0}")
V1 = FFVideoSource("{0}")
AudioDub(V1, A1).ConvertToRGB32(matrix="PC.709")
Deshaker("19|2|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|0|2|8|30|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|15|1|1|30|30|0|0|1|0|1|1|1|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff")
ConvertToYV12()
"""
		content = content.format(name, plugin_name)

		with self.output().open('w') as f:
			f.write(content)


class DeshakeAllPasses(luigi.Task):
	path = luigi.Parameter()

	def requires(self):
		return {
			'CountFrames': CountFrames(self.path),
			'SecondPass': DeshakeSecondPass(self.path),
			'FirstPass': DeshakeFirstPass(self.path)
		}

	def output(self):
		return luigi.LocalTarget("./ps-avisynth-deshake/work_dir/deshake.%s.all.jobs" % _stem(self.path))

	def run(self):
		with self.input().get('CountFrames').open('r') as frame_count, \
			self.input().get('FirstPass').open('r') as first_pass, \
			self.input().get('SecondPass').open('r') as second_pass, \
			open(os.path.join(os.path.dirname(__file__), "deshake.template.jobs"), mode='r') as all_job_file, \
			self.output().open('w') as output_file:

			frame_count_name = re.match('\\d+', frame_count.readline()).group(0)
			first_pass_name = _windows_path(first_pass.name, escape_backslash=True)
			second_pass_name = _windows_path(second_pass.name, escape_backslash=True)
			path_parts = os.path.splitext(str(self.path))
			output_name = _windows_path(path_parts[0] + "-deshake.AVI", escape_backslash=True)

			content = all_job_file.read().format(first_pass_name, second_pass_name, output_name, frame_count_name)
			output_file.write(content)
