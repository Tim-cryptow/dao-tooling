(define-trait governance-exec-trait
  (
    (proposals (uint) (response (tuple (for-votes uint) (against-votes uint) (executed bool)) uint))
    (approved-spends (uint) (response (tuple (recipient principal) (amount uint)) uint))
  )
)
