;; Simple governance trait
(define-trait governance-trait
  (
    ;; Get proposal details
    (get-proposal (uint) (response {
      proposer: principal,
      for-votes: uint,
      against-votes: uint,
      executed: bool
    } uint))
    
    ;; Get spend details
    (get-spend (uint) (response {
      recipient: principal,
      amount: uint
    } uint))
  )
)
