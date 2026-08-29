; mojibake.ahk -- Global keyboard REAL mojibake garbler (AHK v2)
; Type a word + SPACE -> word becomes authentic, decodable mojibake
; (UTF-8 bytes misread as Windows-1252 -- the real-world encoding bug)
;
; The output can be decoded back to the original by:
;   encoding the garbled text as CP1252, then decoding as UTF-8
;
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
    ; Step 1: Promote ASCII letters to accented Unicode so they become
    ;         multi-byte in UTF-8. Each letter has multiple options picked
    ;         randomly for variety. All are in different Unicode ranges
    ;         (U+00C0-U+024F, U+1E00-U+1EFF) so the resulting mojibake
    ;         bytes are diverse, not a wall of identical pairs.
    ;
    ; Step 2: Encode promoted text as UTF-8, re-read as CP1252.
    ;         This is REAL mojibake -- decodable by reversing the process.
    ;
    ; Codepoints stored as decimals (pure ASCII source).

    static tbl := Map()

    if (tbl.Count = 0) {
        ; Each letter -> array of accented variants from spread-out Unicode ranges
        ; Mixing Latin Extended, Latin Extended Additional, etc.
        ; so the 2-byte UTF-8 lead bytes vary (C3, C4, C5, C6, C7, E1...)

        ; a: 0xE0(a-grave) 0xE3(a-tilde) 0x0101(a-macron) 0x0105(a-ogonek) 0x1EA1(a-dot-below)
        tbl["a"] := [0xE0, 0xE3, 0x0101, 0x0105, 0x1EA1]
        ; b: 0x0180(b-stroke) 0x0253(b-hook) 0x1E03(b-dot-above) 0x1E05(b-dot-below)
        tbl["b"] := [0x0180, 0x0253, 0x1E03, 0x1E05]
        ; c: 0xE7(c-cedilla) 0x0107(c-acute) 0x010D(c-caron) 0x1E09(c-cedilla-acute)
        tbl["c"] := [0xE7, 0x0107, 0x010D, 0x1E09]
        ; d: 0x010F(d-caron) 0x0111(d-stroke) 0x1E0B(d-dot-above) 0x1E0D(d-dot-below)
        tbl["d"] := [0x010F, 0x0111, 0x1E0B, 0x1E0D]
        ; e: 0xE8(e-grave) 0xEB(e-diaeresis) 0x0113(e-macron) 0x011B(e-caron) 0x1EB9(e-dot-below)
        tbl["e"] := [0xE8, 0xEB, 0x0113, 0x011B, 0x1EB9]
        ; f: 0x0192(f-hook) 0x1E1F(f-dot-above)
        tbl["f"] := [0x0192, 0x1E1F]
        ; g: 0x011D(g-circumflex) 0x0121(g-dot-above) 0x01E7(g-caron) 0x1E21(g-macron)
        tbl["g"] := [0x011D, 0x0121, 0x01E7, 0x1E21]
        ; h: 0x0125(h-circumflex) 0x0127(h-stroke) 0x1E23(h-dot-above) 0x1E27(h-diaeresis)
        tbl["h"] := [0x0125, 0x0127, 0x1E23, 0x1E27]
        ; i: 0xEC(i-grave) 0xEF(i-diaeresis) 0x012B(i-macron) 0x0133(ij) 0x1ECB(i-dot-below)
        tbl["i"] := [0xEC, 0xEF, 0x012B, 0x0133, 0x1ECB]
        ; j: 0x0135(j-circumflex) 0x01F0(j-caron) 0x0249(j-stroke)
        tbl["j"] := [0x0135, 0x01F0, 0x0249]
        ; k: 0x0137(k-cedilla) 0x01E9(k-caron) 0x1E31(k-acute) 0x1E33(k-dot-below)
        tbl["k"] := [0x0137, 0x01E9, 0x1E31, 0x1E33]
        ; l: 0x013A(l-acute) 0x013E(l-caron) 0x0142(l-stroke) 0x1E37(l-dot-below)
        tbl["l"] := [0x013A, 0x013E, 0x0142, 0x1E37]
        ; m: 0x1E41(m-dot-above) 0x1E43(m-dot-below) 0x0271(m-hook)
        tbl["m"] := [0x1E41, 0x1E43, 0x0271]
        ; n: 0xF1(n-tilde) 0x0144(n-acute) 0x0148(n-caron) 0x1E45(n-dot-above) 0x1E49(n-line-below)
        tbl["n"] := [0xF1, 0x0144, 0x0148, 0x1E45, 0x1E49]
        ; o: 0xF2(o-grave) 0xF5(o-tilde) 0xF8(o-stroke) 0x014D(o-macron) 0x1ECD(o-dot-below)
        tbl["o"] := [0xF2, 0xF5, 0xF8, 0x014D, 0x1ECD]
        ; p: 0x1E55(p-acute) 0x1E57(p-dot-above)
        tbl["p"] := [0x1E55, 0x1E57]
        ; q: 0x024B(q-hook-tail)
        tbl["q"] := [0x024B]
        ; r: 0x0155(r-acute) 0x0159(r-caron) 0x1E59(r-dot-above) 0x1E5B(r-dot-below)
        tbl["r"] := [0x0155, 0x0159, 0x1E59, 0x1E5B]
        ; s: 0x015B(s-acute) 0x0161(s-caron) 0x015F(s-cedilla) 0x1E63(s-dot-below)
        tbl["s"] := [0x015B, 0x0161, 0x015F, 0x1E63]
        ; t: 0x0165(t-caron) 0x0167(t-stroke) 0x1E6B(t-dot-above) 0x1E6D(t-dot-below)
        tbl["t"] := [0x0165, 0x0167, 0x1E6B, 0x1E6D]
        ; u: 0xF9(u-grave) 0xFC(u-diaeresis) 0x016B(u-macron) 0x0173(u-ogonek) 0x1EE5(u-dot-below)
        tbl["u"] := [0xF9, 0xFC, 0x016B, 0x0173, 0x1EE5]
        ; v: 0x1E7D(v-tilde) 0x1E7F(v-dot-below) 0x028B(v-hook)
        tbl["v"] := [0x1E7D, 0x1E7F, 0x028B]
        ; w: 0x0175(w-circumflex) 0x1E81(w-grave) 0x1E83(w-acute) 0x1E85(w-diaeresis)
        tbl["w"] := [0x0175, 0x1E81, 0x1E83, 0x1E85]
        ; x: 0x1E8B(x-dot-above) 0x1E8D(x-diaeresis)
        tbl["x"] := [0x1E8B, 0x1E8D]
        ; y: 0xFD(y-acute) 0xFF(y-diaeresis) 0x0177(y-circumflex) 0x1EF3(y-grave)
        tbl["y"] := [0xFD, 0xFF, 0x0177, 0x1EF3]
        ; z: 0x017A(z-acute) 0x017E(z-caron) 0x017C(z-dot-above) 0x1E93(z-dot-below)
        tbl["z"] := [0x017A, 0x017E, 0x017C, 0x1E93]

        ; Uppercase
        tbl["A"] := [0xC0, 0xC3, 0x0100, 0x0104, 0x1EA0]
        tbl["B"] := [0x0181, 0x1E02, 0x1E04]
        tbl["C"] := [0xC7, 0x0106, 0x010C, 0x1E08]
        tbl["D"] := [0x010E, 0x0110, 0x1E0A, 0x1E0C]
        tbl["E"] := [0xC8, 0xCB, 0x0112, 0x011A, 0x1EB8]
        tbl["F"] := [0x1E1E]
        tbl["G"] := [0x011C, 0x0120, 0x01E6, 0x1E20]
        tbl["H"] := [0x0124, 0x0126, 0x1E22, 0x1E26]
        tbl["I"] := [0xCC, 0xCF, 0x012A, 0x1ECA]
        tbl["J"] := [0x0134, 0x0248]
        tbl["K"] := [0x0136, 0x01E8, 0x1E30, 0x1E32]
        tbl["L"] := [0x0139, 0x013D, 0x0141, 0x1E36]
        tbl["M"] := [0x1E40, 0x1E42]
        tbl["N"] := [0xD1, 0x0143, 0x0147, 0x1E44, 0x1E48]
        tbl["O"] := [0xD2, 0xD5, 0xD8, 0x014C, 0x1ECC]
        tbl["P"] := [0x1E54, 0x1E56]
        tbl["Q"] := [0x024A]
        tbl["R"] := [0x0154, 0x0158, 0x1E58, 0x1E5A]
        tbl["S"] := [0x015A, 0x0160, 0x015E, 0x1E62]
        tbl["T"] := [0x0164, 0x0166, 0x1E6A, 0x1E6C]
        tbl["U"] := [0xD9, 0xDC, 0x016A, 0x0172, 0x1EE4]
        tbl["V"] := [0x1E7C, 0x1E7E]
        tbl["W"] := [0x0174, 0x1E80, 0x1E82, 0x1E84]
        tbl["X"] := [0x1E8A, 0x1E8C]
        tbl["Y"] := [0xDD, 0x0178, 0x0176, 0x1EF2]
        tbl["Z"] := [0x0179, 0x017D, 0x017B, 0x1E92]
    }

    ; Step 1: promote each letter to a random accented variant
    promoted := ""
    for ch in StrSplit(s) {
        if tbl.Has(ch) {
            opts := tbl[ch]
            promoted .= Chr(opts[Random(1, opts.Length)])
        } else {
            promoted .= ch
        }
    }

    ; Step 2: real mojibake -- UTF-8 bytes reinterpreted as CP1252
    buf := Buffer(StrPut(promoted, "UTF-8"))
    StrPut(promoted, buf, "UTF-8")
    return StrGet(buf, "CP1252")
}

ToggleMoji(*) {
    global enabled
    enabled := !enabled
    ToolTip(enabled ? "Mojibake: ON" : "Mojibake: OFF")
    SetTimer(() => ToolTip(), -1500)
}

^!m::ToggleMoji()
^!q::ExitApp
