;; Treasury trait definition
(define-trait treasury-trait
  (
    ;; Spend funds based on a proposal
    (spend (uint) (response bool uint))
    
    ;; Get the treasury balance
    (get-balance () (response uint uint))
  )
)
