;; Test the Governance contract

;; Initialize accounts for testing
(define-constant wallet-1 tx-sender) ;; Admin
(define-constant wallet-2 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-constant wallet-3 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Test proposing
(define-private (test-propose)
  (begin
    (print "Testing propose function")
    
    ;; First add wallet-2 as a member
    (contract-call? .dao-core add-member wallet-2)
    
    ;; Create a proposal as wallet-2
    (as-contract (stx-transfer? u1000000 tx-sender wallet-2))
    (let ((proposal-id (unwrap-panic (as-contract (contract-call? .governance propose u200 .dao-core)))))
      ;; Check that the proposal was created
      (asserts! (is-eq proposal-id u1) (err "Proposal ID should be 1"))
      
      ;; Get the proposal and check its properties
      (let ((proposal (contract-call? .governance get-proposal u1)))
        (asserts! (is-ok proposal) (err "Should be able to get proposal"))
        (asserts! (is-eq (get proposer (unwrap-panic proposal)) wallet-2) (err "Proposer should be wallet-2"))
        (asserts! (is-eq (get for-votes (unwrap-panic proposal)) u0) (err "For votes should be 0"))
        (asserts! (is-eq (get against-votes (unwrap-panic proposal)) u0) (err "Against votes should be 0"))
        (asserts! (not (get executed (unwrap-panic proposal))) (err "Proposal should not be executed"))
      )
      
      (print "✓ propose test passed")
      (ok true)
    )
  )
)

;; Test voting
(define-private (test-vote)
  (begin
    (print "Testing vote function")
    
    ;; Add wallet-3 as a member
    (contract-call? .dao-core add-member wallet-3)
    
    ;; Vote on the proposal as wallet-2 (for)
    (let ((vote-result (as-contract (contract-call? .governance vote u1 true .dao-core))))
      (asserts! (is-ok vote-result) (err "Wallet-2 should be able to vote"))
      
      ;; Vote on the proposal as wallet-3 (against)
      (as-contract (contract-call? .governance vote u1 false .dao-core))
      
      ;; Check the vote counts
      (let ((proposal (contract-call? .governance get-proposal u1)))
        (asserts! (is-eq (get for-votes (unwrap-panic proposal)) u1) (err "For votes should be 1"))
        (asserts! (is-eq (get against-votes (unwrap-panic proposal)) u1) (err "Against votes should be 1"))
      )
      
      ;; Try to vote again as wallet-2 (should fail)
      (asserts! (is-err (as-contract (contract-call? .governance vote u1 true .dao-core))) (err "Should not be able to vote twice"))
      
      (print "✓ vote test passed")
      (ok true)
    )
  )
)

;; Test propose-spend
(define-private (test-propose-spend)
  (begin
    (print "Testing propose-spend function")
    
    ;; Create a spend proposal as wallet-2
    (let ((proposal-id (unwrap-panic (as-contract (contract-call? .governance propose-spend u200 wallet-3 u1000 .dao-core)))))
      ;; Check that the proposal was created
      (asserts! (is-eq proposal-id u2) (err "Proposal ID should be 2"))
      
      ;; Get the proposal and check its properties
      (let ((proposal (contract-call? .governance get-proposal u2)))
        (asserts! (is-ok proposal) (err "Should be able to get proposal"))
        
        ;; Get the spend data
        (let ((spend-data (contract-call? .governance get-spend u2)))
          (asserts! (is-ok spend-data) (err "Should be able to get spend data"))
          (asserts! (is-eq (get recipient (unwrap-panic spend-data)) wallet-3) (err "Recipient should be wallet-3"))
          (asserts! (is-eq (get amount (unwrap-panic spend-data)) u1000) (err "Amount should be 1000"))
        )
      )
      
      (print "✓ propose-spend test passed")
      (ok true)
    )
  )
)

;; Run all tests
(define-public (run-tests)
  (begin
    (print "Running Governance tests...")
    (unwrap-panic (test-propose))
    (unwrap-panic (test-vote))
    (unwrap-panic (test-propose-spend))
    (print "All Governance tests passed!")
    (ok true)
  )
)
