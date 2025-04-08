;; Simple governance contract
(use-trait dao-member-trait .dao-core-trait.dao-core-trait)
(use-trait treasury-trait .treasury-trait.treasury-trait)

;; Constants
(define-constant MIN_DURATION u100)
(define-constant ERR_NOT_MEMBER u101)
(define-constant ERR_DURATION_TOO_SHORT u102)
(define-constant ERR_PROPOSAL_NOT_FOUND u103)
(define-constant ERR_ALREADY_VOTED u104)
(define-constant ERR_VOTING_NOT_STARTED u107)
(define-constant ERR_VOTING_ENDED u108)
(define-constant ERR_ALREADY_EXECUTED u112)
(define-constant ERR_VOTING_IN_PROGRESS u113)
(define-constant ERR_PROPOSAL_REJECTED u114)

;; Data structures
(define-data-var next-id uint u1)

(define-map proposals-data uint {
  proposer: principal,
  start-height: uint,
  duration: uint,
  for-votes: uint,
  against-votes: uint,
  executed: bool
})

(define-map votes-data { pid: uint, voter: principal } bool)

(define-map spends-data uint {
  recipient: principal,
  amount: uint
})

;; Core functions
(define-public (propose (duration uint) (dao-core <dao-member-trait>))
  (let ((pid (var-get next-id)))
    ;; Check if sender is a member
    (asserts! (unwrap-panic (contract-call? dao-core is-member tx-sender)) (err ERR_NOT_MEMBER))
    
    ;; Check minimum duration
    (asserts! (>= duration MIN_DURATION) (err ERR_DURATION_TOO_SHORT))
    
    ;; Create proposal
    (map-set proposals-data pid {
      proposer: tx-sender,
      start-height: block-height,
      duration: duration,
      for-votes: u0,
      against-votes: u0,
      executed: false
    })
    
    ;; Increment counter
    (var-set next-id (+ pid u1))
    
    (ok pid)
  )
)

(define-public (propose-spend (duration uint) (recipient principal) (amount uint) (dao-core <dao-member-trait>))
  (let ((pid (var-get next-id)))
    ;; Check if sender is a member
    (asserts! (unwrap-panic (contract-call? dao-core is-member tx-sender)) (err ERR_NOT_MEMBER))
    
    ;; Check minimum duration
    (asserts! (>= duration MIN_DURATION) (err ERR_DURATION_TOO_SHORT))
    
    ;; Create proposal
    (map-set proposals-data pid {
      proposer: tx-sender,
      start-height: block-height,
      duration: duration,
      for-votes: u0,
      against-votes: u0,
      executed: false
    })
    
    ;; Store spend data
    (map-set spends-data pid {
      recipient: recipient,
      amount: amount
    })
    
    ;; Increment counter
    (var-set next-id (+ pid u1))
    
    (ok pid)
  )
)

(define-public (vote (pid uint) (support bool) (dao-core <dao-member-trait>))
  (let ((proposal (unwrap! (map-get? proposals-data pid) (err ERR_PROPOSAL_NOT_FOUND))))
    ;; Check if sender is a member
    (asserts! (unwrap-panic (contract-call? dao-core is-member tx-sender)) (err ERR_NOT_MEMBER))
    
    ;; Check if already voted
    (asserts! (is-none (map-get? votes-data { pid: pid, voter: tx-sender })) (err ERR_ALREADY_VOTED))
    
    ;; Check if voting has started
    (asserts! (>= block-height (get start-height proposal)) (err ERR_VOTING_NOT_STARTED))
    
    ;; Check if voting has ended
    (asserts! (< block-height (+ (get start-height proposal) (get duration proposal))) (err ERR_VOTING_ENDED))
    
    ;; Record vote
    (map-set votes-data { pid: pid, voter: tx-sender } support)
    
    ;; Update vote count
    (if support
      (map-set proposals-data pid (merge proposal { for-votes: (+ (get for-votes proposal) u1) }))
      (map-set proposals-data pid (merge proposal { against-votes: (+ (get against-votes proposal) u1) }))
    )
    
    (ok true)
  )
)

(define-public (execute (pid uint) (treasury <treasury-trait>))
  (let ((proposal (unwrap! (map-get? proposals-data pid) (err ERR_PROPOSAL_NOT_FOUND))))
    ;; Check if already executed
    (asserts! (not (get executed proposal)) (err ERR_ALREADY_EXECUTED))
    
    ;; Check if voting period has ended
    (asserts! (>= block-height (+ (get start-height proposal) (get duration proposal))) (err ERR_VOTING_IN_PROGRESS))
    
    ;; Check if proposal passed
    (asserts! (> (get for-votes proposal) (get against-votes proposal)) (err ERR_PROPOSAL_REJECTED))
    
    ;; Mark as executed
    (map-set proposals-data pid (merge proposal { executed: true }))
    
    ;; Execute spend if it exists
    (match (map-get? spends-data pid)
      spend-data (contract-call? treasury spend pid)
      (ok true)
    )
  )
)

;; Read-only functions
(define-read-only (get-proposal (pid uint))
  (ok (unwrap! (map-get? proposals-data pid) (err ERR_PROPOSAL_NOT_FOUND)))
)

(define-read-only (get-spend (pid uint))
  (ok (unwrap! (map-get? spends-data pid) (err ERR_PROPOSAL_NOT_FOUND)))
)
