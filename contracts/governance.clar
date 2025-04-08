(define-constant MIN_DURATION u100)
(define-constant TREASURY_CONTRACT 'SPWY51QX7AE44KFB1JA7BK5D2V3YK0QJZ06WG7DR.treasury) ;; Replace with actual contract address

(define-data-var next-proposal-id uint u1)
(define-map proposals uint {
  proposer: principal,
  description: (buff 256),
  start-height: uint,
  duration: uint,
  for-votes: uint,
  against-votes: uint,
  executed: bool
})
(define-map votes { proposal-id: uint, voter: principal } bool)
(define-map approved-spends uint {
  recipient: principal,
  amount: uint
})

(define-public (propose (desc (buff 256)) (duration uint))
  (let (
    (pid (var-get next-proposal-id))
    (start block-height)
  )
    (asserts! (>= duration MIN_DURATION) (err u102))
    (var-set next-proposal-id (+ pid u1))
    (map-set proposals pid {
      proposer: tx-sender,
      description: desc,
      start-height: start,
      duration: duration,
      for-votes: u0,
      against-votes: u0,
      executed: false
    })
    (ok pid)
  )
)

(define-public (propose-spend (desc (buff 256)) (duration uint) (recipient principal) (amount uint))
  (let (
    (pid (var-get next-proposal-id))
    (start block-height)
  )
    (asserts! (>= duration MIN_DURATION) (err u102))
    (var-set next-proposal-id (+ pid u1))
    (map-set proposals pid {
      proposer: tx-sender,
      description: desc,
      start-height: start,
      duration: duration,
      for-votes: u0,
      against-votes: u0,
      executed: false
    })
    (map-set approved-spends pid {
      recipient: recipient,
      amount: amount
    })
    (ok pid)
  )
)

(define-public (vote (proposal-id uint) (support bool))
  (let (
    (proposal (map-get? proposals proposal-id))
    (has-voted (map-get? votes { proposal-id: proposal-id, voter: tx-sender }))
  )
    (asserts! (is-some proposal) (err u103))
    (asserts! (is-none has-voted) (err u104))
    (map-set votes { proposal-id: proposal-id, voter: tx-sender } support)

    (let (
      (start (get start-height (unwrap! proposal (err u105))))
      (duration (get duration (unwrap! proposal (err u106))))
    )
      (asserts! (>= block-height start) (err u107))
      (asserts! (< block-height (+ start duration)) (err u108))

      (if support
        (map-set proposals proposal-id (merge proposal {
          for-votes: (+ (get for-votes (unwrap! proposal (err u109))) u1)
        }))
        (map-set proposals proposal-id (merge proposal {
          against-votes: (+ (get against-votes (unwrap! proposal (err u110))) u1)
        }))
      )
      (ok true)
    )
  )
)

(define-public (execute (proposal-id uint))
  (let ((proposal (unwrap! (map-get? proposals proposal-id) (err u111))))
    (asserts! (not (get executed proposal)) (err u112))
    (asserts! (>= block-height (+ (get start-height proposal) (get duration proposal))) (err u113))
    (asserts! (> (get for-votes proposal) (get against-votes proposal)) (err u114))
    (map-set proposals proposal-id (merge proposal { executed: true }))
    (match (map-get? approved-spends proposal-id)
      spend-data
        (contract-call? TREASURY_CONTRACT spend proposal-id)
      none
        (ok true)
    )
  )
)

(define-read-only (proposals (proposal-id uint))
  (unwrap-panic (map-get? proposals proposal-id))
)

(define-read-only (approved-spends (proposal-id uint))
  (unwrap-panic (map-get? approved-spends proposal-id))
)
