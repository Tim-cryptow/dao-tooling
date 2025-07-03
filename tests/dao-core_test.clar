;; Test the DAO Core contract

;; Initialize accounts for testing
(define-constant wallet-1 tx-sender) ;; Admin
(define-constant wallet-2 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-constant wallet-3 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Test adding a member
(define-private (test-add-member)
  (begin
    (print "Testing add-member function")
    
    ;; Admin adds wallet-2 as a member
    (asserts! (is-ok (contract-call? .dao-core add-member wallet-2)) (err "Failed to add member"))
    
    ;; Check if wallet-2 is now a member
    (asserts! (unwrap-panic (contract-call? .dao-core is-member wallet-2)) (err "Wallet-2 should be a member"))
    
    ;; Check that wallet-3 is not a member
    (asserts! (not (unwrap-panic (contract-call? .dao-core is-member wallet-3))) (err "Wallet-3 should not be a member"))
    
    (print "✓ add-member test passed")
    (ok true)
  )
)

;; Test removing a member
(define-private (test-remove-member)
  (begin
    (print "Testing remove-member function")
    
    ;; First add wallet-3 as a member
    (asserts! (is-ok (contract-call? .dao-core add-member wallet-3)) (err "Failed to add member"))
    
    ;; Check if wallet-3 is now a member
    (asserts! (unwrap-panic (contract-call? .dao-core is-member wallet-3)) (err "Wallet-3 should be a member"))
    
    ;; Remove wallet-3 as a member
    (asserts! (is-ok (contract-call? .dao-core remove-member wallet-3)) (err "Failed to remove member"))
    
    ;; Check that wallet-3 is no longer a member
    (asserts! (not (unwrap-panic (contract-call? .dao-core is-member wallet-3))) (err "Wallet-3 should not be a member"))
    
    (print "✓ remove-member test passed")
    (ok true)
  )
)

;; Test transferring admin
(define-private (test-transfer-admin)
  (begin
    (print "Testing transfer-admin function")
    
    ;; Transfer admin to wallet-2
    (asserts! (is-ok (contract-call? .dao-core transfer-admin wallet-2)) (err "Failed to transfer admin"))
    
    ;; Check that wallet-2 is now the admin
    (asserts! (is-eq (unwrap-panic (contract-call? .dao-core get-admin)) wallet-2) (err "Wallet-2 should be the admin"))
    
    ;; Try to add a member as wallet-1 (should fail)
    (asserts! (is-err (as-contract (contract-call? .dao-core add-member wallet-3))) (err "Non-admin should not be able to add members"))
    
    ;; Transfer admin back to wallet-1 for other tests
    (as-contract (contract-call? .dao-core transfer-admin wallet-1))
    
    (print "✓ transfer-admin test passed")
    (ok true)
  )
)

;; Run all tests
(define-public (run-tests)
  (begin
    (print "Running DAO Core tests...")
    (unwrap-panic (test-add-member))
    (unwrap-panic (test-remove-member))
    (unwrap-panic (test-transfer-admin))
    (print "All DAO Core tests passed!")
    (ok true)
  )
)
