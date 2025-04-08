;; Simple treasury contract
(impl-trait .treasury-trait.treasury-trait)
(use-trait governance-trait .governance-trait.governance-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED u300)
(define-constant ERR_INSUFFICIENT_FUNDS u301)
(define-constant ERR_INVALID_CALLER u302)

;; Store the governance contract address
(define-data-var governance-contract principal tx-sender)

;; Set the governance contract
(define-public (set-governance (governance principal))
  (begin
    (var-set governance-contract governance)
    (ok true)
  )
)

;; Check if caller is the governance contract
(define-private (is-governance)
  (is-eq tx-sender (var-get governance-contract))
)

;; Public functions
(define-public (deposit (amount uint))
  (stx-transfer? amount tx-sender (as-contract tx-sender))
)

(define-public (spend (pid uint))
  (begin
    ;; Check if caller is the governance contract
    (asserts! (is-governance) (err ERR_UNAUTHORIZED))
    
    ;; Get the governance contract
    (let (
      (governance-contract-principal (var-get governance-contract))
    )
      ;; Get proposal data
      (match (as-contract (contract-call? .governance get-proposal pid))
        proposal-ok proposal-ok
        proposal-err (err ERR_INVALID_CALLER)
      )
      
      ;; Get spend data
      (match (as-contract (contract-call? .governance get-spend pid))
        spend-ok
          (let (
            (proposal (unwrap-panic (as-contract (contract-call? .governance get-proposal pid))))
          )
            ;; Check if not executed
            (asserts! (not (get executed proposal)) (err ERR_UNAUTHORIZED))
            
            ;; Check if enough funds
            (asserts! (<= (get amount spend-ok) (as-contract (stx-get-balance tx-sender))) (err ERR_INSUFFICIENT_FUNDS))
            
            ;; Transfer funds
            (as-contract (stx-transfer? (get amount spend-ok) tx-sender (get recipient spend-ok)))
          )
        spend-err (err ERR_INVALID_CALLER)
      )
    )
  )
)

;; Read-only functions
(define-read-only (get-balance)
  (ok (as-contract (stx-get-balance tx-sender)))
)
