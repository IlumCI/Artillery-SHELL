; mojibake.ahk -- Global keyboard mojibake garbler (AHK v2)
; Type a word + SPACE -> word is replaced with wild mojibake
; Toggle: Ctrl+Alt+M    Quit: Ctrl+Alt+Q
; Save as UTF-8 with BOM, or plain ANSI -- both work.

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
    if (vk = 0x08) {                                        ; Backspace
        word := SubStr(word, 1, StrLen(word) - 1)
    } else if (vk = 0x0D || vk = 0x09                       ; Enter / Tab
            || (vk >= 0x21 && vk <= 0x28)) {                 ; arrows / pgup etc
        word := ""
    }
}

Garble(s) {
    ; Each ASCII letter gets a unique high-Unicode replacement chosen to
    ; produce maximally wild-looking mojibake when UTF-8 bytes are read
    ; as CP1252.  The codes span CJK, Cyrillic, Arabic, Thai, Georgian,
    ; Devanagari, symbols -- so the output is visually chaotic.
    ;
    ; Stored as decimal codepoints so the .ahk source stays pure ASCII.

    static lo := Map()
    static hi := Map()

    if (lo.Count = 0) {
        ; lowercase a-z -> scattered Unicode codepoints
        codes_lo := [
            0x0416,  ; a -> Zh (Cyrillic)
            0x0E3A,  ; b -> Thai
            0x4E16,  ; c -> CJK "world"
            0x0636,  ; d -> Arabic Dad
            0x03A8,  ; e -> Greek Psi
            0x2603,  ; f -> Snowman
            0x10D0,  ; g -> Georgian
            0x0926,  ; h -> Devanagari Da
            0x2654,  ; i -> Chess King
            0x0E17,  ; j -> Thai
            0x03A9,  ; k -> Greek Omega
            0x0429,  ; l -> Cyrillic Shcha
            0x2620,  ; m -> Skull
            0x4E01,  ; n -> CJK "person"
            0x0E2D,  ; o -> Thai
            0x2666,  ; p -> Diamond suit
            0x0642,  ; q -> Arabic Qaf
            0x0394,  ; r -> Greek Delta
            0x2602,  ; s -> Umbrella
            0x0E23,  ; t -> Thai
            0x042F,  ; u -> Cyrillic Ya
            0x2660,  ; v -> Spade suit
            0x4E8C,  ; w -> CJK "two"
            0x2665,  ; x -> Heart suit
            0x03A6,  ; y -> Greek Phi
            0x2663   ; z -> Club suit
        ]
        codes_hi := [
            0x0414,  ; A -> Cyrillic De
            0x0E01,  ; B -> Thai
            0x4E09,  ; C -> CJK "three"
            0x0639,  ; D -> Arabic Ain
            0x03A3,  ; E -> Greek Sigma
            0x2605,  ; F -> Black Star
            0x10D1,  ; G -> Georgian
            0x0921,  ; H -> Devanagari
            0x2655,  ; I -> Chess Queen
            0x0E19,  ; J -> Thai
            0x03A0,  ; K -> Greek Pi
            0x0426,  ; L -> Cyrillic Tse
            0x2622,  ; M -> Radioactive
            0x4E03,  ; N -> CJK "seven"
            0x0E2A,  ; O -> Thai
            0x2667,  ; P -> White Club
            0x0648,  ; Q -> Arabic Waw
            0x0398,  ; R -> Greek Theta
            0x2604,  ; S -> Comet
            0x0E25,  ; T -> Thai
            0x0424,  ; U -> Cyrillic Ef
            0x2662,  ; V -> White Diamond
            0x4E5D,  ; W -> CJK "nine"
            0x2661,  ; X -> White Heart
            0x039E,  ; Y -> Greek Xi
            0x2664   ; Z -> White Spade
        ]

        alpha := "abcdefghijklmnopqrstuvwxyz"
        Loop 26 {
            letter := SubStr(alpha, A_Index, 1)
            lo[letter] := Chr(codes_lo[A_Index])
            hi[StrUpper(letter)] := Chr(codes_hi[A_Index])
        }
    }

    out := ""
    for ch in StrSplit(s) {
        if hi.Has(ch)
            out .= hi[ch]
        else if lo.Has(ch)
            out .= lo[ch]
        else
            out .= ch
    }

    ; Now do the classic mojibake: encode as UTF-8, decode as CP1252
    buf := Buffer(StrPut(out, "UTF-8"))
    StrPut(out, buf, "UTF-8")
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
