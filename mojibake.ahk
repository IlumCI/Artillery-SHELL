; mojibake.ahk -- Global keyboard mojibake garbler (AHK v2)
; Type a word + SPACE -> word is replaced with diverse Unicode weirdness
; Toggle: Ctrl+Alt+M    Quit: Ctrl+Alt+Q

#Requires AutoHotkey v2.0
#SingleInstance Force

global word := ""
global enabled := true

ih := InputHook("V I1")
ih.OnChar    := OnChar
ih.OnKeyDown := OnKeyDown
ih.KeyOpt("{All}", "N")
ih.Start()

OnChar(h, c) {
    global word, enabled
    if (c = " ") {
        if (word != "" && enabled) {
            garbled := Garble(word)
            Send("{BS " StrLen(word) "}")
            SendText(garbled . " ")
        }
        word := ""
    } else {
        word .= c
    }
}

OnKeyDown(h, vk, sc) {
    global word
    if (vk = 0x08)
        word := SubStr(word, 1, StrLen(word) - 1)
    else if (vk = 0x0D || vk = 0x09 || (vk >= 0x21 && vk <= 0x28))
        word := ""
}

Garble(s) {
    ; Each letter has 4 replacements from different scripts/styles.
    ; One is picked at random per character, so repeated letters look different.
    ; No re-encoding -- these are the actual displayed characters.
    ;
    ; All stored as decimal codepoints (pure ASCII source).

    static tbl := Map()

    if (tbl.Count = 0) {
        ; a: Cyrillic-a, Greek-alpha, Fullwidth-a, Math-bold-a
        tbl["a"] := [0x0430, 0x03B1, 0xFF41, 0x1D41A]
        ; b: Cyrillic-ve, Fullwidth-b, Math-bold-b, Cherokee-hna
        tbl["b"] := [0x0432, 0xFF42, 0x1D41B, 0x13F4]
        ; c: Cyrillic-es, Fullwidth-c, Math-bold-c, Armenian-co
        tbl["c"] := [0x0441, 0xFF43, 0x1D41C, 0x03F2]
        ; d: Fullwidth-d, Math-bold-d, Eth, Georgian-don
        tbl["d"] := [0xFF44, 0x1D41D, 0x00F0, 0x10D3]
        ; e: Cyrillic-ie, Greek-epsilon, Fullwidth-e, Math-bold-e
        tbl["e"] := [0x0435, 0x03B5, 0xFF45, 0x1D41E]
        ; f: Fullwidth-f, Math-bold-f, Florin, Latin-f-hook
        tbl["f"] := [0xFF46, 0x1D41F, 0x0192, 0xA799]
        ; g: Fullwidth-g, Math-bold-g, Script-g, Georgian
        tbl["g"] := [0xFF47, 0x1D420, 0x0261, 0x10D6]
        ; h: Cyrillic-ha, Fullwidth-h, Math-bold-h, Planck-h
        tbl["h"] := [0x04BB, 0xFF48, 0x1D421, 0x210E]
        ; i: Cyrillic-i-short dotless, Greek-iota, Fullwidth-i, Math-bold-i
        tbl["i"] := [0x0456, 0x03B9, 0xFF49, 0x1D422]
        ; j: Fullwidth-j, Math-bold-j, Latin-j-crossed, Dotless-j
        tbl["j"] := [0xFF4A, 0x1D423, 0x0249, 0x0237]
        ; k: Cyrillic-ka, Fullwidth-k, Math-bold-k, Kra
        tbl["k"] := [0x043A, 0xFF4B, 0x1D424, 0x0138]
        ; l: Fullwidth-l, Math-bold-l, Latin-l-bar, Script-l
        tbl["l"] := [0xFF4C, 0x1D425, 0x019A, 0x2113]
        ; m: Fullwidth-m, Math-bold-m, Cyrillic-em, Latin-m-hook
        tbl["m"] := [0xFF4D, 0x1D426, 0x043C, 0x0271]
        ; n: Fullwidth-n, Math-bold-n, Greek-nu, Latin-eng
        tbl["n"] := [0xFF4E, 0x1D427, 0x03BD, 0x014B]
        ; o: Cyrillic-o, Greek-omicron, Fullwidth-o, Math-bold-o
        tbl["o"] := [0x043E, 0x03BF, 0xFF4F, 0x1D428]
        ; p: Cyrillic-er, Greek-rho, Fullwidth-p, Math-bold-p
        tbl["p"] := [0x0440, 0x03C1, 0xFF50, 0x1D429]
        ; q: Fullwidth-q, Math-bold-q, Latin-q-hook, Coptic
        tbl["q"] := [0xFF51, 0x1D42A, 0x024B, 0x03D9]
        ; r: Fullwidth-r, Math-bold-r, Latin-r-fishhook, Small-cap-r
        tbl["r"] := [0xFF52, 0x1D42B, 0x027E, 0x0280]
        ; s: Fullwidth-s, Math-bold-s, Greek-sigma, Long-s
        tbl["s"] := [0xFF53, 0x1D42C, 0x03C2, 0x017F]
        ; t: Fullwidth-t, Math-bold-t, Latin-t-retroflex, Thorn
        tbl["t"] := [0xFF54, 0x1D42D, 0x0288, 0x00FE]
        ; u: Fullwidth-u, Math-bold-u, Greek-upsilon, Cyrillic-u-short
        tbl["u"] := [0xFF55, 0x1D42E, 0x03C5, 0x045E]
        ; v: Fullwidth-v, Math-bold-v, Latin-v-hook, Cyrillic-izhitsa
        tbl["v"] := [0xFF56, 0x1D42F, 0x028B, 0x0475]
        ; w: Fullwidth-w, Math-bold-w, Latin-w-hook, Omega
        tbl["w"] := [0xFF57, 0x1D430, 0x2C73, 0x03C9]
        ; x: Cyrillic-ha, Fullwidth-x, Math-bold-x, Multiply-x
        tbl["x"] := [0x0445, 0xFF58, 0x1D431, 0x00D7]
        ; y: Cyrillic-u, Greek-gamma, Fullwidth-y, Math-bold-y
        tbl["y"] := [0x0443, 0x03B3, 0xFF59, 0x1D432]
        ; z: Fullwidth-z, Math-bold-z, Latin-z-retroflex, Yogh
        tbl["z"] := [0xFF5A, 0x1D433, 0x0290, 0x021D]

        ; uppercase versions
        tbl["A"] := [0x0410, 0x0391, 0xFF21, 0x1D400]
        tbl["B"] := [0x0412, 0xFF22, 0x1D401, 0x13F4]
        tbl["C"] := [0x0421, 0xFF23, 0x1D402, 0x03F9]
        tbl["D"] := [0xFF24, 0x1D403, 0x00D0, 0x13A0]
        tbl["E"] := [0x0415, 0x0395, 0xFF25, 0x1D404]
        tbl["F"] := [0xFF26, 0x1D405, 0xA798, 0x03DC]
        tbl["G"] := [0xFF27, 0x1D406, 0x050C, 0x13C0]
        tbl["H"] := [0x041D, 0xFF28, 0x1D407, 0x0397]
        tbl["I"] := [0x0406, 0xFF29, 0x1D408, 0x0196]
        tbl["J"] := [0xFF2A, 0x1D409, 0x0248, 0x037F]
        tbl["K"] := [0x041A, 0xFF2B, 0x1D40A, 0x13E6]
        tbl["L"] := [0xFF2C, 0x1D40B, 0x13DE, 0x2112]
        tbl["M"] := [0x041C, 0xFF2D, 0x1D40C, 0x13B7]
        tbl["N"] := [0xFF2E, 0x1D40D, 0x039D, 0x13B9]
        tbl["O"] := [0x041E, 0x039F, 0xFF2F, 0x1D40E]
        tbl["P"] := [0x0420, 0x03A1, 0xFF30, 0x1D40F]
        tbl["Q"] := [0xFF31, 0x1D410, 0x2D55, 0x051A]
        tbl["R"] := [0xFF32, 0x1D411, 0x13A1, 0x01A6]
        tbl["S"] := [0xFF33, 0x1D412, 0x03A3, 0x13D5]
        tbl["T"] := [0xFF34, 0x1D413, 0x03A4, 0x13A2]
        tbl["U"] := [0xFF35, 0x1D414, 0x03A5, 0x054D]
        tbl["V"] := [0xFF36, 0x1D415, 0x0474, 0x13D9]
        tbl["W"] := [0xFF37, 0x1D416, 0x13B3, 0x051C]
        tbl["X"] := [0x0425, 0xFF38, 0x1D417, 0x13CC]
        tbl["Y"] := [0x0423, 0xFF39, 0x1D418, 0x04AE]
        tbl["Z"] := [0xFF3A, 0x1D419, 0x13C3, 0x01B5]
    }

    out := ""
    for ch in StrSplit(s) {
        if tbl.Has(ch) {
            opts := tbl[ch]
            pick := opts[Random(1, opts.Length)]
            out .= Chr(pick)
        } else {
            out .= ch
        }
    }
    return out
}

ToggleMoji(*) {
    global enabled
    enabled := !enabled
    ToolTip(enabled ? "Mojibake: ON" : "Mojibake: OFF")
    SetTimer(() => ToolTip(), -1500)
}

^!m::ToggleMoji()
^!q::ExitApp
