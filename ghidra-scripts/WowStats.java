// Ghidra post-script: report basic stats about the analyzed Wow.exe
import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.Function;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.listing.Data;

public class WowStats extends GhidraScript {
    public void run() throws Exception {
        int fn = 0;
        for (Function f : currentProgram.getFunctionManager().getFunctions(true)) fn++;
        int sym = currentProgram.getSymbolTable().getNumSymbols();
        int data = 0;
        for (Data d : currentProgram.getListing().getDefinedData(true)) data++;
        println("=== Wow.exe 分析统计 ===");
        println("functions = " + fn);
        println("symbols   = " + sym);
        println("data      = " + data);
        println("language  = " + currentProgram.getLanguageID());
        println("compiler  = " + currentProgram.getCompilerSpec().getCompilerSpecID());
        println("imagebase = " + currentProgram.getImageBase());
    }
}