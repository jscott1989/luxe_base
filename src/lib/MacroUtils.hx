package lib;

/**
 * From https://gist.github.com/nitrobin/8c5f724ec2da8e88ff73
 */
class MacroUtils {
    public function new() {
    }

    /** Подставляет на этапе компиляции в код значение переданное компилятору через флаг -D (Например: -DsetLanguage=ru )*/
    macro public static function getDefinedValue(key:haxe.macro.Expr, defaultValue:haxe.macro.Expr) {
        function getString(v:haxe.macro.Expr):String {
            return switch(v.expr) {
                case EConst(CString(str)):
                    str;
                default:
                    null;
            }
        }
        var _key:String = getString(key);
        var _defaultValue:String = getString(defaultValue);
        var value = haxe.macro.Context.definedValue(_key);
        if (value == null) {
            return haxe.macro.Context.makeExpr(_defaultValue, haxe.macro.Context.currentPos());
        } else {
            return haxe.macro.Context.makeExpr(value, haxe.macro.Context.currentPos());
        }
    }
}
