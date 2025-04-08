(define-data-var dao-admin principal tx-sender)
(define-map members principal bool)

(define-public (add-member (new-member principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-admin)) (err u100))
    (map-set members new-member true)
    (ok true)
  )
)

(define-public (remove-member (ex-member principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-admin)) (err u100))
    (map-delete members ex-member)
    (ok true)
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get dao-admin)) (err u101))
    (var-set dao-admin new-admin)
    (ok true)
  )
)

(define-read-only (is-member (user principal))
  (ok (default-to false (map-get? members user)))
)

(define-read-only (get-admin)
  (ok (var-get dao-admin))
)
