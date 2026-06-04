// Batch max projection for 3D stacks in Fiji/ImageJ
// Works on TIFF files in a folder and saves Max Intensity projections

macro "Batch Max Projection" {
    inputDir = getDirectory("Choose input folder");
    outputDir = getDirectory("Choose output folder");
    list = getFileList(inputDir);

    setBatchMode(true);

    for (i = 0; i < list.length; i++) {
        name = list[i];

        if (File.isDirectory(inputDir + name))
            continue;

        if (!(endsWith(toLowerCase(name), ".tif") || endsWith(toLowerCase(name), ".tiff")))
            continue;

        open(inputDir + name);
        origTitle = getTitle();

        // Max intensity projection across all Z slices
        run("Z Project...", "projection=[Max Intensity]");

        projTitle = getTitle();

        base = origTitle;
        dot = lastIndexOf(base, ".");
        if (dot != -1)
            base = substring(base, 0, dot);

        saveAs("Tiff", outputDir + base + "_MAX.tif");

        close(); // closes projection
        selectWindow(origTitle);
        close(); // closes original stack
    }

    setBatchMode(false);
    print("Done.");
}