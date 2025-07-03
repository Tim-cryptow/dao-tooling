;; Test the Treasury contract

;; Initialize accounts for testing
(define-constant wallet-1 tx-sender) ;; Admin
(define-constant wallet-2 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-constant wallet-3 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Test deposit
(define-private (test-deposit)
  (begin
    (print "Testing deposit function")
    
    ;; Get initial balance
    (let ((initial-balance (unwrap-panic (contract-call? .treasury get-balance))))
      
      ;; Deposit 5000 STX
      (as-contract (stx-transfer? u5000 tx-sender .treasury))
      (asserts! (is-ok (contract-call? .treasury deposit u5000)) (err "Deposit should succeed"))
      
      ;; Check new balance
      (let ((new-balance (unwrap-panic (contract-call? .treasury get-balance))))
        (asserts! (> new-balance initial-balance) (err "Balance should increase after deposit"))
        
        (print "✓ deposit test passed")
        (ok true)
      )
    )
  )
)

;; Test setting governance
(define-private (test-set-governance)
  (begin
    (print "Testing set-governance function")
    
    ;; Set governance to wallet-2
    (asserts! (is-ok (contract-call? .treasury set-governance .governance)) (err "Set governance should succeed"))
    
    (print "✓ set-governance test passed")
    (ok true)
  )
)

;; Run all tests
(define-public (run-tests)
  (begin
    (print "Running Treasury tests...")
    (unwrap-panic (test-deposit))
    (unwrap-panic (test-set-governance))
    (print "All Treasury tests passed!")
    (ok true)
  )
)
