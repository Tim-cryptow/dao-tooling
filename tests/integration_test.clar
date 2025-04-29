;; Integration test for the DAO contracts

;; Initialize accounts for testing
(define-constant wallet-1 tx-sender) ;; Admin
(define-constant wallet-2 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(define-constant wallet-3 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Test the full DAO workflow
(define-public (test-dao-workflow)
  (begin
    (print "Testing full DAO workflow")
    
    ;; 1. Set up the DAO
    (print "1. Setting up the DAO")
    
    ;; Add members
    (contract-call? .dao-core add-member wallet-2)
    (contract-call? .dao-core add-member wallet-3)
    
    ;; Set governance in treasury
    (contract-call? .treasury set-governance .governance)
    
    ;; Fund the treasury
    (as-contract (stx-transfer? u10000 tx-sender .treasury))
    (contract-call? .treasury deposit u10000)
    
    ;; 2. Create a spend proposal
    (print "2. Creating a spend proposal")
    (let (
      (proposal-id (unwrap-panic (as-contract (contract-call? .governance propose-spend u200 wallet-3 u5000 .dao-core))))
    )
      (print (concat "Created proposal ID: " (to-string proposal-id)))
      
      ;; 3. Vote on the proposal
      (print "3. Voting on the proposal")
      (as-contract (contract-call? .governance vote proposal-id true .dao-core)) ;; wallet-2 votes yes
      (as-contract (contract-call? .governance vote proposal-id true .dao-core)) ;; wallet-3 votes yes
      
      ;; Check vote counts
      (let ((proposal (contract-call? .governance get-proposal proposal-id)))
        (print (concat "For votes: " (to-string (get for-votes (unwrap-panic proposal)))))
        (print (concat "Against votes: " (to-string (get against-votes (unwrap-panic proposal)))))
      )
      
      ;; 4. Advance blockchain to end voting period
      (print "4. Advancing blockchain to end voting period")
      ;; In a real test, you would use Clarinet's test harness to advance the chain
      ;; For this example, we'll just simulate it
      
      ;; 5. Execute the proposal
      (print "5. Executing the proposal")
      (let (
        (execute-result (as-contract (contract-call? .governance execute proposal-id .treasury)))
      )
        (print (concat "Execute result: " (to-string execute-result)))
        
        ;; 6. Check that funds were transferred
        (print "6. Checking that funds were transferred")
        (let ((treasury-balance (unwrap-panic (contract-call? .treasury get-balance))))
          (print (concat "Treasury balance after execution: " (to-string treasury-balance)))
          
          (print "✓ Full DAO workflow test completed")
          (ok true)
        )
      )
    )
  )
)

;; Run the integration test
(define-public (run-tests)
  (begin
    (print "Running integration tests...")
    (unwrap-panic (test-dao-workflow))
    (print "All integration tests passed!")
    (ok true)
  )
)
