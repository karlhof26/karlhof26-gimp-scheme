; Shrek text
; Copyright (c) 2004 Ivan Zenkov <ivan.zenkov@gmail.com>
;
;
; Based on iText tutorial by Craig Marshall 
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
; 
; Updsated to work with Gimp2.4 (11-2007)
; http://www.gimpscripts.com
;

(define (script-fu-shrek-text-kh string font-name font-size text-color)
    
  (let* (
            (text-ext (gimp-text-get-extents-fontname string font-size 0 font-name))
            (wid (+ (car text-ext) 20))
            (hig (+ (cadr text-ext) 20))
            (img (car (gimp-image-new wid hig 0)))
            (bg-layer (car (gimp-layer-new img wid hig 0 "Background" 100 0)))
            (shadow-layer (car (gimp-layer-new img wid hig 1 "Shadow" 100 0)))
            (text-layer (car (gimp-layer-new img wid hig 1 "Text" 100 0)))
            (glow-layer (car (gimp-layer-new img wid hig 1 "Glow layer (first)" 100 0)))
            (glow-layer-second (car (gimp-layer-new img wid hig 1 "Glow layer (first)" 100 0)))
            (plastic-layer (car (gimp-layer-new img wid hig 1 "Plastic effect" 100 0)))
            (text-channel (car (gimp-channel-new img wid hig "Text channel" 50 '(0 0 0))))
            (shrink-num (/ (caddr text-ext) (* (/ (/ (caddr text-ext) 3.3) (caddr text-ext)) 100)))
            (blur-num (/ (caddr text-ext) 10))
            (old-fg (car (gimp-palette-get-foreground)))
            (old-bg (car (gimp-palette-get-background)))
        )
        
        (gimp-image-undo-disable img)
        
        (gimp-image-insert-layer img bg-layer 0 1)
        (gimp-image-insert-layer img shadow-layer 0 -1)
        (gimp-image-insert-layer img text-layer 0 -1)
        (gimp-image-insert-layer img glow-layer 0 -1)
        (gimp-image-insert-layer img plastic-layer 0 -1)
        (gimp-image-add-channel img text-channel 0)
        
        (gimp-context-set-background '(255 255 255))
        (gimp-edit-clear bg-layer)
        (gimp-edit-clear shadow-layer)
        (gimp-edit-clear text-layer)
        (gimp-edit-clear glow-layer)
        (gimp-edit-clear plastic-layer)
        (gimp-context-set-background '(0 0 0))
        (gimp-edit-clear text-channel)
        
        (gimp-context-set-foreground text-color)
        (gimp-floating-sel-anchor (car (gimp-text-fontname img text-layer 10 10 string 0 TRUE font-size PIXELS font-name)))
        
        ; glow effect
        (gimp-selection-layer-alpha text-layer)
        (gimp-selection-shrink img shrink-num)
        (gimp-edit-fill glow-layer 2)
        (gimp-layer-set-mode glow-layer 5)
        (gimp-selection-none img)
        (plug-in-gauss-iir2 1 img glow-layer blur-num blur-num)
        
        
        ;; ugly code
        (set! glow-layer-second (car (gimp-layer-copy glow-layer 0)))
        (gimp-layer-set-name glow-layer-second "Glow layer (second)")
        (gimp-image-insert-layer img glow-layer-second 0 -1)
        (gimp-layer-set-mode glow-layer-second 5)
        (set! text-layer (car (gimp-image-merge-down img glow-layer-second 2)))
        (set! text-layer (car (gimp-image-merge-down img glow-layer 2)))
        
        ; blur channel
        (gimp-edit-copy text-layer)
        (gimp-floating-sel-anchor (car (gimp-edit-paste text-channel 0)))
        (plug-in-gauss-iir2 1 img text-channel (/ blur-num 2) (/ blur-num 2))
        (gimp-drawable-set-visible text-channel 0)
        
        ; plastic effect
        (gimp-edit-fill plastic-layer 1)
        (gimp-layer-set-mode plastic-layer 4)
        (plug-in-lighting 1 img plastic-layer text-channel 0 TRUE FALSE 0 0 '(255 255 255) 1 0 1 -1 -1 1 0.30 1 0.40 0.60 27 TRUE FALSE FALSE)
        (set! text-layer (car (gimp-image-merge-down img plastic-layer 2)))
        
        
        
        ; shadow
        (gimp-selection-layer-alpha text-layer)
        (gimp-edit-fill shadow-layer 1)
        (gimp-selection-none img)
        (plug-in-gauss-iir2 1 img shadow-layer 1 1)
        
        ; I can't use script-fu-drop-shadow :-(
        ; ERROR: wta(1st) to min (see errobj)
        ; Please fix it.
        
        
        
        
        (script-fu-drop-shadow img shadow-layer 3.0 3.0 3.0 '(0 0 0) 100.0 TRUE)
        
        ; I can't delete channel
        ; ERROR: Procedural database execution failed:
        ;   (gimp_drawable_delete 66)
        ; Please fix it.
        ;    (gimp-drawable-delete text-channel)
        
        (gimp-context-set-foreground old-fg)
        (gimp-context-set-background old-bg)
        
        (gimp-image-undo-enable img)
        (gimp-display-new img)
  )
)

(script-fu-register "script-fu-shrek-text-kh"
    "Shrek Text Logo kh"
    "Give text a iMac effect. kh\nfiile:shrek-text.scm"
    "Ivan Zenkov"
    "Ivan Zenkov"
    "September 17, 2004"
    ""
    SF-STRING     "Text"                "Shrek"
    SF-FONT       "Font"                "Serif Bold"
    SF-ADJUSTMENT "Font Size (pixels)"  '(100 2 1000 1 10 0 1)
    SF-COLOR      "Text Color"          '(84 155 8)
)

(script-fu-menu-register "script-fu-shrek-text-kh"
    "<Toolbox>/Script-Fu/Logos/"
)

;end of script