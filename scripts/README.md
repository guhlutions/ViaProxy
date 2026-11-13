# Realm test build

The `realm-fixes` branches of [ViaProxy](https://github.com/guhlutions/ViaProxy/tree/realm-fixes) and [ViaBedrock](https://github.com/guhlutions/ViaBedrock/tree/realm-fixes) contain the source used in the combined JAR. This build uses the original dependencies from ViaProxy `7b9b9b5` and ViaBedrock `33c0ec6a`.

To recreate it, check out both branches and extract the modern `ViaProxy-3.4.15-SNAPSHOT.jar` from the upstream [Build run](https://github.com/ViaVersion/ViaProxy/actions/runs/42425026928). The script checks the stock JAR's SHA-256 before compiling the changes. Use a JDK with `javac` and `jar` on your PATH, or set `JAVAC` and `JAR` to their full paths.

```sh
./scripts/build-realm-jar.sh /path/to/ViaProxy-3.4.15-SNAPSHOT.jar ../ViaBedrock ../ViaProxy.jar
```

On this Mac, keep `ViaProxy starten.command` next to `ViaProxy.jar` and double-click it in Finder. The script uses Homebrew's Java 25 and the existing `~/minecraft-viaproxy` runtime directory, where ViaProxy stores accounts, settings, and logs.
