A1 = FFAudioSource("{0}")
V1 = FFVideoSource("{0}")
AudioDub(V1, A1).ConvertToRGB32(matrix="PC.709")
WriteFile("{1}", "FrameCount")
