// Batch open .czi files with Bio-Formats, split channels, save each channel as TIFF
// Works for 3D stacks / hyperstacks

macro "Batch Split CZI Channels (Bio-Formats)" {

    inputDir = getDirectory("Choose input folder with CZI files");
    outputDir = getDirectory("Choose output folder");
    list = getFileList(inputDir);

    setBatchMode(true);

    for (i = 0; i < list.length; i++) {
        name = list[i];

        if (File.isDirectory(inputDir + name))
            continue;

        if (!endsWith(toLowerCase(name), ".czi"))
            continue;

        // Open with Bio-Formats as hyperstack
        run("Bio-Formats Importer", 
            "open=[" + inputDir + name + "] " +
            "autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");

        origTitle = getTitle();

        // Split channels
        run("Split Channels");

        // Base name without extension
        base = origTitle;
        dot = lastIndexOf(base, ".");
        if (dot != -1)
            base = substring(base, 0, dot);

        titles = getList("image.titles");

        for (j = 0; j < titles.length; j++) {
            t = titles[j];

            // Split channels are usually named like C1-filename, C2-filename...
            if (startsWith(t, "C") && indexOf(t, "-" + origTitle) != -1) {
                selectWindow(t);

                dash = indexOf(t, "-");
                ch = substring(t, 0, dash); // C1, C2, C3...

                saveAs("Tiff", outputDir + base + "_" + ch + ".tif");
                close();
            }
        }

        // Close original hyperstack if still open
        if (isOpen(origTitle)) {
            selectWindow(origTitle);
            close();
        }
    }

    setBatchMode(false);
    print("Done.");
}