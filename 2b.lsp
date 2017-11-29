(defun sset-map  (sset proc / result)
  (setq i   0
        len (sslength sset))
  (while (< i len)
    (setq result (cons (proc (ssname sset i)) result)
          i      (1+ i)))
  result)

(defun sset->list  (sset)
  (sset-map sset (lambda (x) x)))

(defun get-vla-boxes  ()
  (vl-remove-if-not
    '(lambda (box)
       (= "AcDb3dSolid" (vla-get-objectname box)))
    (mapcar 'vlax-ename->vla-object (sset->list (ssget)))))

(defun str-format  (str templates values / i)
  (setq i 0)
  (while (< i (length templates))
    (setq str (vl-string-subst (nth i values) (nth i templates) str)
          i   (1+ i)))
  str)

(defun make-panel  (box / minp maxp)
  (vla-getboundingbox box 'minp 'maxp)
  (setq minp  (safearray-value minp)
        maxp  (safearray-value maxp)

        x-min (car minp)
        y-min (cadr minp)
        z-min (caddr minp)

        x-max (car maxp)
        y-max (cadr maxp)
        z-max (caddr maxp)

        dims  (mapcar '- maxp minp)
        dx    (car dims)
        dy    (cadr dims)
        dz    (caddr dims)

        layer (vla-get-layer box)
        th    (min dx dy dz))

  (cond ((= th dy)                      ;front panel
         (princ
           (str-format
             "ActiveMaterial.Make('layer', th); AddFrontPanel(p1-min, p1-max, p2-min, p2-max, shift);"
             '("p1-min" "p1-max" "p2-min" "p2-max" "shift" "layer" "th")
             (mapcar '(lambda (item)
                        (if (numberp item)
                          (rtos item)
                          item))
                     (list x-min
                           z-min
                           x-max
                           z-max
                           (- y-max)
                           layer
                           th)))))
        ((= th dz)                       ;hor panel
         (princ
           (str-format
             "ActiveMaterial.Make('layer', th); AddHorizPanel(p1-min, p1-max, p2-min, p2-max, shift);"
             '("p1-min" "p1-max" "p2-min" "p2-max" "shift" "layer" "th")
             (mapcar '(lambda (item)
                        (if (numberp item)
                          (rtos item)
                          item))
                     (list x-min
                           (- y-min)
                           x-max
                           (- y-max)
                           z-min
                           layer
                           th)))))
        ((= th dx)                       ;vert panel
         (princ
           (str-format
             "ActiveMaterial.Make('layer', th); AddVertPanel(p1-min, p1-max, p2-min, p2-max, shift);"
             '("p1-min" "p1-max" "p2-min" "p2-max" "shift" "layer" "th")
             (mapcar '(lambda (item)
                        (if (numberp item)
                          (rtos item)
                          item))
                     (list (- y-min)
                           z-min
                           (- y-max)
                           z-max
                           x-min
                           layer
                           th)))))))

(defun c:2b  ()
  (setq script "")
  (foreach box  (get-vla-boxes)
    (setq script (strcat script (make-panel box) "\n")))
  (vlax-invoke
    (vlax-get (vlax-get (vlax-create-object "htmlfile") 'parentwindow) 'clipboarddata)
    'setdata
    "TEXT"
    script))
