#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none, outlined: false)[#ez_caption[Online supplementary code][在线补充代码]]

#parec[
  Editorial note: The following code is present in the fixed online source’s expanded panels, although the printed discussion explicitly omits it. Repeated expanded copies are included only once. These fragments retain their original context dependencies.
][
  校订说明：以下代码存在于固定在线原文的展开面板中，但印刷正文明确省略了它们。重复展开的副本只保留一份；代码仍依赖原有上下文，并非可独立编译的程序。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragbit-7")[#raw("<<Process command-line arguments>>")]]
```cpp
for (auto iter = args.begin(); iter != args.end(); ++iter) {
    if ((*iter)[0] != '-') {
        filenames.push_back(*iter);
        continue;
    }

    auto onError = [](const std::string &err) {
        usage(err);
        exit(1);
    };

    std::string cropWindow, pixelBounds, pixel, pixelMaterial;
    if (ParseArg(&iter, args.end(), "cropwindow", &cropWindow, onError)) {
        std::vector<Float> c = SplitStringToFloats(cropWindow, ',');
        if (c.size() != 4) {
            usage("Didn't find four values after --cropwindow");
            return 1;
        }
        options.cropWindow = Bounds2f(Point2f(c[0], c[2]), Point2f(c[1], c[3]));
    } else if (ParseArg(&iter, args.end(), "pixel", &pixel, onError)) {
        std::vector<int> p = SplitStringToInts(pixel, ',');
        if (p.size() != 2) {
            usage("Didn't find two values after --pixel");
            return 1;
        }
        options.pixelBounds =
            Bounds2i(Point2i(p[0], p[1]), Point2i(p[0] + 1, p[1] + 1));
    } else if (ParseArg(&iter, args.end(), "pixelbounds", &pixelBounds, onError)) {
        std::vector<int> p = SplitStringToInts(pixelBounds, ',');
        if (p.size() != 4) {
            usage("Didn't find four integer values after --pixelbounds");
            return 1;
        }
        options.pixelBounds = Bounds2i(Point2i(p[0], p[2]), Point2i(p[1], p[3]));
    } else if (ParseArg(&iter, args.end(), "pixelmaterial", &pixelMaterial, onError)) {
        std::vector<int> p = SplitStringToInts(pixelMaterial, ',');
        if (p.size() != 2) {
            usage("Didn't find two values after --pixelmaterial");
            return 1;
        }
        options.pixelMaterial = Point2i(p[0], p[1]);
    } else if (
#ifdef PBRT_BUILD_GPU_RENDERER
        ParseArg(&iter, args.end(), "gpu", &options.useGPU, onError) ||
        ParseArg(&iter, args.end(), "gpu-device", &options.gpuDevice, onError) ||
#endif
        ParseArg(&iter, args.end(), "debugstart", &options.debugStart, onError) ||
        ParseArg(&iter, args.end(), "disable-pixel-jitter", &options.disablePixelJitter,
                 onError) ||
        ParseArg(&iter, args.end(), "disable-texture-filtering",
                 &options.disableTextureFiltering, onError) ||
        ParseArg(&iter, args.end(), "disable-wavelength-jitter", &options.disableWavelengthJitter,
                 onError) ||
        ParseArg(&iter, args.end(), "displacement-edge-scale",
                 &options.displacementEdgeScale, onError) ||
        ParseArg(&iter, args.end(), "display-server", &options.displayServer, onError) ||
        ParseArg(&iter, args.end(), "force-diffuse", &options.forceDiffuse, onError) ||
        ParseArg(&iter, args.end(), "format", &format, onError) ||
        ParseArg(&iter, args.end(), "log-level", &logLevel, onError) ||
        ParseArg(&iter, args.end(), "log-utilization", &options.logUtilization, onError) ||
        ParseArg(&iter, args.end(), "log-file", &options.logFile, onError) ||
        ParseArg(&iter, args.end(), "mse-reference-image", &options.mseReferenceImage, onError) ||
        ParseArg(&iter, args.end(), "mse-reference-out", &options.mseReferenceOutput, onError) ||
        ParseArg(&iter, args.end(), "nthreads", &options.nThreads, onError) ||
        ParseArg(&iter, args.end(), "outfile", &options.imageFile, onError) ||
        ParseArg(&iter, args.end(), "pixelstats", &options.recordPixelStatistics, onError) ||
        ParseArg(&iter, args.end(), "quick", &options.quickRender, onError) ||
        ParseArg(&iter, args.end(), "quiet", &options.quiet, onError) ||
        ParseArg(&iter, args.end(), "render-coord-sys", &renderCoordSys, onError) ||
        ParseArg(&iter, args.end(), "seed", &options.seed, onError) ||
        ParseArg(&iter, args.end(), "spp", &options.pixelSamples, onError) ||
        ParseArg(&iter, args.end(), "stats", &options.printStatistics, onError) ||
        ParseArg(&iter, args.end(), "toply", &toPly, onError) ||
        ParseArg(&iter, args.end(), "wavefront", &options.wavefront, onError) ||
        ParseArg(&iter, args.end(), "write-partial-images", &options.writePartialImages,
                 onError) ||
        ParseArg(&iter, args.end(), "upgrade", &options.upgrade, onError)) {
        // success
    } else if (*iter == "--help" || *iter == "-help" || *iter == "-h") {
        usage();
        return 0;
    } else {
        usage(StringPrintf("argument \"%s\" unknown", *iter));
        return 1;
    }
}
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragbit-25")[#raw("<<Optionally write current image to disk>>")]]
```cpp
if (waveStart == spp || Options->writePartialImages || referenceImage) {
    ImageMetadata metadata;
    metadata.renderTimeSeconds = progress.ElapsedSeconds();
    metadata.samplesPerPixel = waveStart;
    if (waveStart == spp || Options->writePartialImages) {
        camera.InitMetadata(&metadata);
        camera.GetFilm().WriteImage(metadata, 1.0f / waveStart);
    }
}
```
