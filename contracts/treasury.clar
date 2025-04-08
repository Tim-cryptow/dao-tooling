;; Implements the governance trait defined in a separate contract
(impl-trait 'SP21G72C5JTKS9P8AD5X8JQBBV9JY2A9B08945C77.governance-trait::governance-exec-trait)

(define-constant GOVERNANCE_CONTRACT 'SP21G72C5JTKS9P8AD5X8JQBBV9JY2A9B08945C77.governance)

(define-public (deposit)
  (ok true)
)

(define-public (spend (proposal-id uint))
  (let (
    (proposal (contract-call? GOVERNANCE_CONTRACT proposals proposal-id))
  )
    (match proposal
      proposal-data
        (begin
          ;; Only allow spending if NOT executed
          (asserts! (not (get executed proposal-data)) (err u300))

          (let (
            (spend-response (contract-call? GOVERNANCE_CONTRACT approved-spends proposal-id))
          )
            (match spend-response
              spend-data
                (stx-transfer? (get amount spend-data) tx-sender (get recipient spend-data))
              err
                (err u301)
            )
          )
        )
      err
        (err u302)
    )
  )
)

(define-read-only (get-balance)
  (stx-get-balance tx-sender)
)
