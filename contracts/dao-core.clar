;; Simple DAO core contract

;; Constants
(define-constant ERR_UNAUTHORIZED u100)

;; Data structures
(define-data-var admin principal tx-sender)
(define-map members principal bool)

;; Public functions
(define-public (add-member (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR_UNAUTHORIZED))
    (map-set members user true)
    (ok true)
  )
)

(define-public (remove-member (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR_UNAUTHORIZED))
    (map-delete members user)
    (ok true)
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR_UNAUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)

;; Read-only functions
(define-read-only (is-member (user principal))
  (ok (default-to false (map-get? members user)))
)

(define-read-only (get-admin)
  (ok (var-get admin))
)
