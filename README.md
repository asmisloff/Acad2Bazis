# Acad2Bazis
Simple converter from AutoCAD 3d model to БАЗИС-Мебельщик 3d model.
This is AutoCAD lisp script that generates js for Базис. Базис uses generated js for building/recovering the initial model.

Using
----------------
1. Load 2b.lsp into AutoCAD by using "appload" command.
2. Call "2b" command.
3. Select 3dSolids. Each 3dSolid is regarded as a panel (in Bazis meaning). Solids should lay on separate layers by materials.
4. Open Bazis, open script editor, paste script from clipboard (Ctrl-V), run the script (F5).
5. Enjoy.
