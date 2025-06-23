;; Food Supply Chain Tracker
;; A smart contract for tracking food products through the supply chain

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-stage (err u103))
(define-constant err-already-exists (err u104))

;; Data Variables
(define-data-var next-product-id uint u1)

;; Data Maps
(define-map products
    { product-id: uint }
    {
        name: (string-ascii 64),
        producer: principal,
        current-stage: (string-ascii 32),
        origin-location: (string-ascii 64),
        created-at: uint,
        last-updated: uint
    }
)

(define-map product-history
    { product-id: uint, stage-id: uint }
    {
        stage: (string-ascii 32),
        handler: principal,
        location: (string-ascii 64),
        timestamp: uint,
        notes: (string-ascii 128)
    }
)

(define-map authorized-handlers
    { handler: principal }
    { authorized: bool }
)

(define-map product-stage-count
    { product-id: uint }
    { count: uint }
)

;; Authorization Functions
(define-public (authorize-handler (handler principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-handlers { handler: handler } { authorized: true }))
    )
)

(define-public (revoke-handler (handler principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-handlers { handler: handler } { authorized: false }))
    )
)

;; Product Management Functions
(define-public (create-product (name (string-ascii 64)) (origin-location (string-ascii 64)))
    (let ((product-id (var-get next-product-id)))
        (begin
            (map-set products
                { product-id: product-id }
                {
                    name: name,
                    producer: tx-sender,
                    current-stage: "created",
                    origin-location: origin-location,
                    created-at: stacks-block-height,
                    last-updated: stacks-block-height
                }
            )
            (map-set product-stage-count { product-id: product-id } { count: u1 })
            (map-set product-history
                { product-id: product-id, stage-id: u1 }
                {
                    stage: "created",
                    handler: tx-sender,
                    location: origin-location,
                    timestamp: stacks-block-height,
                    notes: "Product created"
                }
            )
            (var-set next-product-id (+ product-id u1))
            (ok product-id)
        )
    )
)

(define-public (update-product-stage 
    (product-id uint) 
    (new-stage (string-ascii 32)) 
    (location (string-ascii 64)) 
    (notes (string-ascii 128)))
    (let (
        (product (unwrap! (map-get? products { product-id: product-id }) err-not-found))
        (stage-count (default-to u0 (get count (map-get? product-stage-count { product-id: product-id }))))
        (is-authorized (default-to false (get authorized (map-get? authorized-handlers { handler: tx-sender }))))
        (is-producer (is-eq tx-sender (get producer product)))
    )
        (begin
            (asserts! (or is-authorized is-producer) err-unauthorized)
            (map-set products
                { product-id: product-id }
                (merge product {
                    current-stage: new-stage,
                    last-updated: stacks-block-height
                })
            )
            (map-set product-stage-count 
                { product-id: product-id } 
                { count: (+ stage-count u1) }
            )
            (map-set product-history
                { product-id: product-id, stage-id: (+ stage-count u1) }
                {
                    stage: new-stage,
                    handler: tx-sender,
                    location: location,
                    timestamp: stacks-block-height,
                    notes: notes
                }
            )
            (ok true)
        )
    )
)

;; Read-only Functions
(define-read-only (get-product (product-id uint))
    (map-get? products { product-id: product-id })
)

(define-read-only (get-product-history (product-id uint) (stage-id uint))
    (map-get? product-history { product-id: product-id, stage-id: stage-id })
)

(define-read-only (get-product-stage-count (product-id uint))
    (default-to u0 (get count (map-get? product-stage-count { product-id: product-id })))
)

(define-read-only (is-handler-authorized (handler principal))
    (default-to false (get authorized (map-get? authorized-handlers { handler: handler })))
)

(define-read-only (get-next-product-id)
    (var-get next-product-id)
)