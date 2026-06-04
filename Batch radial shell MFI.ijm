// ==========================================================
// Batch radial shell MFI macro - MULTIPLE ROIs PER IMAGE
// Supports BOTH circles and ellipses
//
// For each image:
// 1. Opens image
// 2. Applies auto-threshold preview to help ROI drawing
// 3. You draw ONE OR MORE OUTER circular/elliptical ROIs
// 4. Add each ROI to ROI Manager
// 5. Click OK
//
// The macro then measures 4 concentric scaled shells for EACH ROI:
//   0-25%, 25-50%, 50-75%, 75-100%
//
// Outputs:
//   Image, ROI_ID, Shell, Area, Mean, IntDen
//
// Notes:
// - Threshold is only for visual guidance while drawing
// - Measurements are taken from the original image
// - Use oval tool for circle or ellipse
// ==========================================================

macro "Batch radial shell MFI - Circle or Ellipse" {

    dir = getDirectory("Choose input folder");
    list = getFileList(dir);

    if (isOpen("Results")) {
        selectWindow("Results");
        run("Clear Results");
    }

    row = 0;

    for (i = 0; i < list.length; i++) {

        name = list[i];

        if (File.isDirectory(dir + name))
            continue;

        if (!(endsWith(toLowerCase(name), ".tif") || endsWith(toLowerCase(name), ".tiff") ||
              endsWith(toLowerCase(name), ".png") || endsWith(toLowerCase(name), ".jpg") ||
              endsWith(toLowerCase(name), ".jpeg")))
            continue;

        open(dir + name);
        title = getTitle();
        selectWindow(title);

        roiManager("Reset");

        // Auto-threshold preview for drawing
        setAutoThreshold("Default dark");
        run("Threshold...");

        waitForUser(
            "Image: " + title + "\n\n" +
            "Draw ONE OR MORE OUTER ROIs using the OVAL tool.\n" +
            "You may draw either:\n" +
            "- a circle\n" +
            "- or an ellipse\n\n" +
            "Add each ROI to ROI Manager.\n" +
            "When all ROIs are added, click OK."
        );

        if (isOpen("Threshold")) {
            selectWindow("Threshold");
            run("Close");
        }

        if (isOpen(title))
            selectWindow(title);

        nRois = roiManager("Count");
        if (nRois == 0) {
            print("No ROIs found for: " + title + " ... skipping");
            close();
            continue;
        }

        nUserRois = nRois;

        for (r = 0; r < nUserRois; r++) {

            roiManager("Select", r);
            getSelectionBounds(x, y, w, h);

            cx = x + w/2;
            cy = y + h/2;

            // preserve ellipse shape
            w25  = w * 0.25;
            h25  = h * 0.25;
            w50  = w * 0.50;
            h50  = h * 0.50;
            w75  = w * 0.75;
            h75  = h * 0.75;
            w100 = w * 1.00;
            h100 = h * 1.00;

            // =========================
            // Shell 1 = 0-25%
            // =========================
            makeOval(cx - w25/2, cy - h25/2, w25, h25);
            getStatistics(area, mean, min, max, std);
            intDen = area * mean;

            setResult("Image", row, title);
            setResult("ROI_ID", row, r + 1);
            setResult("Shell", row, "0-25%");
            setResult("Area", row, area);
            setResult("Mean", row, mean);
            setResult("IntDen", row, intDen);
            row++;

            // =========================
            // Shell 2 = 25-50%
            // =========================
            makeOval(cx - w25/2, cy - h25/2, w25, h25);
            roiManager("Add");
            idxA = roiManager("Count") - 1;

            makeOval(cx - w50/2, cy - h50/2, w50, h50);
            roiManager("Add");
            idxB = roiManager("Count") - 1;

            roiManager("Select", newArray(idxA, idxB));
            roiManager("XOR");
            getStatistics(area, mean, min, max, std);
            intDen = area * mean;

            setResult("Image", row, title);
            setResult("ROI_ID", row, r + 1);
            setResult("Shell", row, "25-50%");
            setResult("Area", row, area);
            setResult("Mean", row, mean);
            setResult("IntDen", row, intDen);
            row++;

            // =========================
            // Shell 3 = 50-75%
            // =========================
            makeOval(cx - w50/2, cy - h50/2, w50, h50);
            roiManager("Add");
            idxC = roiManager("Count") - 1;

            makeOval(cx - w75/2, cy - h75/2, w75, h75);
            roiManager("Add");
            idxD = roiManager("Count") - 1;

            roiManager("Select", newArray(idxC, idxD));
            roiManager("XOR");
            getStatistics(area, mean, min, max, std);
            intDen = area * mean;

            setResult("Image", row, title);
            setResult("ROI_ID", row, r + 1);
            setResult("Shell", row, "50-75%");
            setResult("Area", row, area);
            setResult("Mean", row, mean);
            setResult("IntDen", row, intDen);
            row++;

            // =========================
            // Shell 4 = 75-100%
            // =========================
            makeOval(cx - w75/2, cy - h75/2, w75, h75);
            roiManager("Add");
            idxE = roiManager("Count") - 1;

            makeOval(cx - w100/2, cy - h100/2, w100, h100);
            roiManager("Add");
            idxF = roiManager("Count") - 1;

            roiManager("Select", newArray(idxE, idxF));
            roiManager("XOR");
            getStatistics(area, mean, min, max, std);
            intDen = area * mean;

            setResult("Image", row, title);
            setResult("ROI_ID", row, r + 1);
            setResult("Shell", row, "75-100%");
            setResult("Area", row, area);
            setResult("Mean", row, mean);
            setResult("IntDen", row, intDen);
            row++;
        }

        updateResults();
        close();
    }

    saveAs("Results", dir + "radial_shell_MFI_results_circle_or_ellipse.csv");
    print("Done. Results saved to: " + dir + "radial_shell_MFI_results_circle_or_ellipse.csv");
}