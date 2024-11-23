;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-landlord (err u100))
(define-constant err-not-tenant (err u101))
(define-constant err-insufficient-funds (err u102))
(define-constant err-no-active-rental (err u103))
(define-constant err-rental-exists (err u104))
(define-constant err-owner-only (err u105))

;; Data variables
(define-map rentals 
    { landlord: principal, tenant: principal }
    { deposit: uint, status: (string-ascii 20) }
)

;; Public functions
(define-public (create-rental (tenant principal) (deposit uint))
    (let ((rental-exists (map-get? rentals { landlord: tx-sender, tenant: tenant })))
        (if (is-some rental-exists)
            err-rental-exists
            (begin 
                (map-set rentals 
                    { landlord: tx-sender, tenant: tenant }
                    { deposit: deposit, status: "pending" }
                )
                (ok true)
            )
        )
    )
)

(define-public (pay-deposit (landlord principal))
    (let (
        (rental (map-get? rentals { landlord: landlord, tenant: tx-sender }))
        (deposit (get deposit (unwrap! rental err-no-active-rental)))
    )
        (if (is-eq (get status (unwrap! rental err-no-active-rental)) "pending")
            (begin
                (try! (stx-transfer? deposit tx-sender (as-contract tx-sender)))
                (map-set rentals 
                    { landlord: landlord, tenant: tx-sender }
                    { deposit: deposit, status: "active" }
                )
                (ok true)
            )
            err-no-active-rental
        )
    )
)

(define-public (return-deposit (tenant principal))
    (let (
        (rental (map-get? rentals { landlord: tx-sender, tenant: tenant }))
        (deposit (get deposit (unwrap! rental err-no-active-rental)))
    )
        (if (is-eq (get status (unwrap! rental err-no-active-rental)) "active")
            (begin
                (try! (as-contract (stx-transfer? deposit tx-sender tenant)))
                (map-delete rentals { landlord: tx-sender, tenant: tenant })
                (ok true)
            )
            err-no-active-rental
        )
    )
)

;; Read only functions
(define-read-only (get-rental (landlord principal) (tenant principal))
    (ok (map-get? rentals { landlord: landlord, tenant: tenant }))
)

(define-read-only (get-contract-owner)
    (ok contract-owner)
)
