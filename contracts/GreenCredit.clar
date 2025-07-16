;; GreenCredit - Decentralized Carbon Credit Marketplace
;; A platform for trading verified carbon credits with transparent tracking

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-not-authorized (err u105))
(define-constant err-invalid-price (err u106))
(define-constant err-credit-retired (err u107))
(define-constant err-invalid-string (err u108))
(define-constant err-invalid-year (err u109))
(define-constant err-invalid-fee (err u110))
(define-constant err-invalid-principal (err u111))

;; Validation constants
(define-constant max-fee u1000) ;; Maximum 10% fee
(define-constant min-vintage-year u1990)
(define-constant max-vintage-year u2050)

;; Data Variables
(define-data-var next-credit-id uint u1)
(define-data-var platform-fee uint u250) ;; 2.5% in basis points

;; Data Maps
(define-map carbon-credits
  { credit-id: uint }
  {
    issuer: principal,
    project-name: (string-ascii 100),
    verification-standard: (string-ascii 50),
    vintage-year: uint,
    total-credits: uint,
    available-credits: uint,
    price-per-credit: uint,
    is-verified: bool,
    is-retired: bool,
    created-at: uint
  }
)

(define-map credit-balances
  { owner: principal, credit-id: uint }
  { balance: uint }
)

(define-map verifier-status
  { verifier: principal }
  { is-authorized: bool }
)

(define-map credit-transactions
  { transaction-id: uint }
  {
    credit-id: uint,
    seller: principal,
    buyer: principal,
    amount: uint,
    price: uint,
    timestamp: uint
  }
)

(define-data-var next-transaction-id uint u1)

;; Private Functions
(define-private (get-credit-balance (owner principal) (credit-id uint))
  (default-to u0 (get balance (map-get? credit-balances { owner: owner, credit-id: credit-id })))
)

(define-private (set-credit-balance (owner principal) (credit-id uint) (new-balance uint))
  (map-set credit-balances { owner: owner, credit-id: credit-id } { balance: new-balance })
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee)) u10000)
)

;; Validation functions
(define-private (is-valid-string (str (string-ascii 100)))
  (> (len str) u0)
)

(define-private (is-valid-verification-standard (standard (string-ascii 50)))
  (> (len standard) u0)
)

(define-private (is-valid-vintage-year (year uint))
  (and (>= year min-vintage-year) (<= year max-vintage-year))
)

(define-private (is-valid-fee (fee uint))
  (<= fee max-fee)
)

;; Public Functions

;; Issue new carbon credits (only authorized verifiers)
(define-public (issue-carbon-credits 
  (project-name (string-ascii 100))
  (verification-standard (string-ascii 50))
  (vintage-year uint)
  (total-credits uint)
  (price-per-credit uint))
  (let (
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
  )
    (asserts! (is-some (map-get? verifier-status { verifier: tx-sender })) err-not-authorized)
    (asserts! (> total-credits u0) err-invalid-amount)
    (asserts! (> price-per-credit u0) err-invalid-price)
    (asserts! (is-valid-string project-name) err-invalid-string)
    (asserts! (is-valid-verification-standard verification-standard) err-invalid-string)
    (asserts! (is-valid-vintage-year vintage-year) err-invalid-year)
    
    (map-set carbon-credits 
      { credit-id: credit-id }
      {
        issuer: tx-sender,
        project-name: project-name,
        verification-standard: verification-standard,
        vintage-year: vintage-year,
        total-credits: total-credits,
        available-credits: total-credits,
        price-per-credit: price-per-credit,
        is-verified: true,
        is-retired: false,
        created-at: current-block
      }
    )
    
    (set-credit-balance tx-sender credit-id total-credits)
    (var-set next-credit-id (+ credit-id u1))
    
    (ok credit-id)
  )
)

;; Purchase carbon credits
(define-public (purchase-credits (credit-id uint) (amount uint))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-not-found))
    (seller (get issuer credit-info))
    (seller-balance (get-credit-balance seller credit-id))
    (price-per-credit (get price-per-credit credit-info))
    (total-cost (* amount price-per-credit))
    (fee-amount (calculate-platform-fee total-cost))
    (seller-amount (- total-cost fee-amount))
    (buyer-current-balance (get-credit-balance tx-sender credit-id))
    (transaction-id (var-get next-transaction-id))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= seller-balance amount) err-insufficient-balance)
    (asserts! (not (get is-retired credit-info)) err-credit-retired)
    
    ;; Update seller balance
    (set-credit-balance seller credit-id (- seller-balance amount))
    
    ;; Update buyer balance
    (set-credit-balance tx-sender credit-id (+ buyer-current-balance amount))
    
    ;; Update available credits
    (map-set carbon-credits 
      { credit-id: credit-id }
      (merge credit-info { available-credits: (- (get available-credits credit-info) amount) })
    )
    
    ;; Record transaction
    (map-set credit-transactions
      { transaction-id: transaction-id }
      {
        credit-id: credit-id,
        seller: seller,
        buyer: tx-sender,
        amount: amount,
        price: price-per-credit,
        timestamp: stacks-block-height
      }
    )
    
    (var-set next-transaction-id (+ transaction-id u1))
    
    ;; Transfer payment (simplified - in real implementation would use STX transfer)
    (ok transaction-id)
  )
)

;; Retire carbon credits (remove from circulation)
(define-public (retire-credits (credit-id uint) (amount uint))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-not-found))
    (owner-balance (get-credit-balance tx-sender credit-id))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= owner-balance amount) err-insufficient-balance)
    
    ;; Reduce owner balance
    (set-credit-balance tx-sender credit-id (- owner-balance amount))
    
    ;; Update available credits
    (map-set carbon-credits 
      { credit-id: credit-id }
      (merge credit-info { available-credits: (- (get available-credits credit-info) amount) })
    )
    
    (ok true)
  )
)

;; Admin function to authorize verifiers
(define-public (authorize-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (is-eq verifier tx-sender)) err-invalid-principal)
    (map-set verifier-status { verifier: verifier } { is-authorized: true })
    (ok true)
  )
)

;; Admin function to update platform fee
(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-valid-fee new-fee) err-invalid-fee)
    (var-set platform-fee new-fee)
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-credit-info (credit-id uint))
  (map-get? carbon-credits { credit-id: credit-id })
)

(define-read-only (get-user-balance (owner principal) (credit-id uint))
  (get-credit-balance owner credit-id)
)

(define-read-only (get-transaction-info (transaction-id uint))
  (map-get? credit-transactions { transaction-id: transaction-id })
)

(define-read-only (is-authorized-verifier (verifier principal))
  (default-to false (get is-authorized (map-get? verifier-status { verifier: verifier })))
)

(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

(define-read-only (get-next-credit-id)
  (var-get next-credit-id)
)