"""Iterator based sre token scanner

"""

//from re import VERBOSE, MULTILINE, DOTALL
//from sre_constants import BRANCH, SUBPATTERN

_CONSTANTS = {
    '-Infinity': NegInf,
    'Infinity': PosInf,
    'NaN': NaN,
    'true': True,
    'false': False,
    'null': None,
}
function JSONConstant(match, context){
    var s = match[0]
    var fn = context.parse_constant
    if (!fn)
        rval = _CONSTANTS[s]
    else
        rval = fn(s)
    return [rval, null]
}
JSONConstant.regex = /(-?Infinity|NaN|true|false|null)/

function JSONNumber(match, context){
    match = this.regex.match(match.string, *match.span())
    integer, frac, exp = match.groups()
    if frac or exp:
        fn = getattr(context, 'parse_float', None) or float
        res = fn(integer + (frac or '') + (exp or ''))
    else:
        fn = getattr(context, 'parse_int', None) or int
        res = fn(integer)
    return res, None
}
JSONNumber.regex = /(-?(?:0|[1-9]\d*))(\.\d+)?([eE][-+]?\d+)?/

function Scanner(lexicon){
    this.actions = [null]
    // Combine phrases into a compound pattern
    var s = sre_parse.Pattern()
    var p = []
    for (var idx = 0; idx < lexicon.length; idx++){
        var token = lexicon[idx]
        var phrase = token.pattern
        subpattern = sre_parse.SubPattern(s,
            [(SUBPATTERN, (idx + 1, sre_parse.parse(phrase, flags)))])
        p.append(subpattern)
        this.actions.append(token)
    }
    s.groups = len(p) + 1 # NOTE(guido): Added to make SRE validation work
    p = sre_parse.SubPattern(s, [(BRANCH, (None, p))])
    this.scanner = sre_compile.compile(p)
}

Scanner.prototype.iterscan = function(string, idx=0, context=None){
        """Yield match, end_idx for each match

        """
        match = this.scanner.scanner(string, idx).match
        actions = this.actions
        lastend = idx
        end = len(string)
        while True:
            m = match()
            if m is None:
                break
            matchbegin, matchend = m.span()
            if lastend == matchend:
                break
            action = actions[m.lastindex]
            if action is not None:
                rval, next_pos = action(m, context)
                if next_pos is not None and next_pos != matchend:
                    # "fast forward" the scanner
                    matchend = next_pos
                    match = this.scanner.scanner(string, matchend).match
                yield rval, matchend
            lastend = matchend
}

function pattern(pattern){
    return function decorator(fn){
        fn.pattern = pattern
        fn.regex = new Regex(pattern)
        return fn
    }
}