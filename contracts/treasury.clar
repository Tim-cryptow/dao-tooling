;; Simple treasury contract
(impl-trait .treasury-trait.treasury-trait)
(use-trait governance-trait .governance-trait.governance-trait)

;; Constants
(define-constant ERR_UNAUTHORIZED u300)
(define-constant ERR_INSUFFICIENT_FUNDS u301)
(define-constant ERR_INVALID_CALLER u302)
(define-constant ERR_PROPOSAL_NOT_FOUND u303)

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
    
    ;; Get proposal data directly with unwrap
    (let (
      (proposal-result (as-contract (contract-call? .governance get-proposal pid)))
    )
      ;; Check if proposal exists and get it
      (asserts! (is-ok proposal-result) (err ERR_PROPOSAL_NOT_FOUND))
      (let (
        (proposal (unwrap-panic proposal-result))
        (spend-result (as-contract (contract-call? .governance get-spend pid)))
      )
        ;; Check if spend data exists
        (asserts! (is-ok spend-result) (err ERR_INVALID_CALLER))
        (let (
          (spend-data (unwrap-panic spend-result))
        )
          ;; Check if not executed
          (asserts! (not (get executed proposal)) (err ERR_UNAUTHORIZED))
          
          ;; Check if enough funds
          (asserts! (<= (get amount spend-data) (as-contract (stx-get-balance tx-sender))) (err ERR_INSUFFICIENT_FUNDS))
          
          ;; Transfer funds
          (as-contract (stx-transfer? (get amount spend-data) tx-sender (get recipient spend-data)))
        )
      )
    )
  )
)

;; Read-only functions
(define-read-only (get-balance)
  (ok (as-contract (stx-get-balance tx-sender)))
)
