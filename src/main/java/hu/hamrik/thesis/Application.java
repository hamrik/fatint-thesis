package hu.hamrik.thesis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import org.nlogo.api.Workspace;
import org.nlogo.headless.HeadlessWorkspace;

class Application {
  public static void main(String[] args) {
    Map<String, Double> params = new HashMap<>();
    for(String arg : args) {
      var parts = arg.split("=");
      if(parts.length == 2) {
        params.put(parts[0], Double.parseDouble(parts[1]));
      }
    }

    runWorkspace(HeadlessWorkspace.newInstance(), params);
  }

  public static void runWorkspace(Workspace workspace, Map<String, Double> params) {
    Path tempDir = null;

    try {
      tempDir = Files.createTempDirectory("fatint").toAbsolutePath();
      extractResource(Paths.get("/model.nlogo"), tempDir);
      workspace.open(tempDir + "/model.nlogo");
    } catch (Exception ex) {
      System.err.println("Exception during setup: " + ex.getMessage());
      ex.printStackTrace();
      System.exit(1);
      return;
    }

    runExperiment(workspace, 60, params, List.of("species-count"));

    try {
      workspace.dispose();
      cleanupTempDir(tempDir);
    } catch (Exception ex) {
      System.err.println("Exception during cleanup: " + ex.getMessage());
      ex.printStackTrace();
    }
  }

  private static Map<String, Object> runExperiment(Workspace workspace, int runs, Map<String, Double> parameters,
      Collection<String> resultNames) {
    for (var p : parameters.entrySet()) {
      workspace.command(String.format("set %s %f", p.getKey(), p.getValue()));
    }

    workspace.command("setup");

    Map<String, Object> results = new HashMap<>();
    for (int i = 0; i < runs; i++) {
      workspace.command("repeat 100 [ go ]");
      for (var r : resultNames) {
        results.put(r, workspace.report(r));
        System.out.println(r + " = " + workspace.report(r));
      }
    }

    return results;
  }

  private static void extractResource(Path src, Path dest) throws IOException {
    var stream = Application.class.getResourceAsStream(src.toString());
    try (FileOutputStream fout = new FileOutputStream(dest.resolve(src.getFileName()).toString())) {
      fout.write(stream.readAllBytes());
    }
  }

  private static void cleanupTempDir(Path target) throws IOException {
    if (target != null) {
      try (Stream<Path> paths = Files.walk(target)) {
        paths.sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
      }
    }
  }

}
