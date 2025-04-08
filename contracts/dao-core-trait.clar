;; Define a trait for the DAO core contract
(define-trait dao-core-trait
  (
    ;; Check if a user is a member
    (is-member (principal) (response bool uint))
    
    ;; Get the current admin
    (get-admin () (response principal uint))
    
    ;; Add a member
    (add-member (principal) (response bool uint))
    
    ;; Remove a member
    (remove-member (principal) (response bool uint))
  )
)
