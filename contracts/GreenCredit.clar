;; GreenCredit - Decentralized Carbon Credit Marketplace
;; A platform for trading verified carbon credits with transparent tracking and multi-standard support

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
(define-constant err-invalid-standard (err u112))
(define-constant err-standard-not-supported (err u113))

;; Validation constants
(define-constant max-fee u1000) ;; Maximum 10% fee
(define-constant min-vintage-year u1990)
(define-constant max-vintage-year u2050)
(define-constant max-string-length u100)
(define-constant max-standard-length u50)
(define-constant max-description-length u200)

;; Supported verification standards
(define-constant standard-vcs "VCS")
(define-constant standard-gold "GOLD")
(define-constant standard-cdm "CDM")
(define-constant standard-car "CAR")
(define-constant standard-acr "ACR")

;; Data Variables
(define-data-var next-credit-id uint u1)
(define-data-var platform-fee uint u250) ;; 2.5% in basis points
(define-data-var next-transaction-id uint u1)

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
    created-at: uint,
    methodology: (string-ascii 100)
  }
)

(define-map credit-balances
  { owner: principal, credit-id: uint }
  { balance: uint }
)

(define-map verifier-status
  { verifier: principal }
  { 
    is-authorized: bool,
    authorized-standards: (list 10 (string-ascii 50))
  }
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

(define-map supported-standards
  { standard: (string-ascii 50) }
  { 
    is-active: bool,
    min-project-size: uint,
    description: (string-ascii 200)
  }
)

;; Initialize supported standards
(map-set supported-standards 
  { standard: standard-vcs }
  { is-active: true, min-project-size: u1, description: "Verified Carbon Standard - World's most used GHG program" })

(map-set supported-standards 
  { standard: standard-gold }
  { is-active: true, min-project-size: u1, description: "Gold Standard - Premium quality carbon credits" })

(map-set supported-standards 
  { standard: standard-cdm }
  { is-active: true, min-project-size: u1, description: "Clean Development Mechanism - UN framework" })

(map-set supported-standards 
  { standard: standard-car }
  { is-active: true, min-project-size: u1, description: "Climate Action Reserve - North American standard" })

(map-set supported-standards 
  { standard: standard-acr }
  { is-active: true, min-project-size: u1, description: "American Carbon Registry - US-focused standard" })

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
  (and (> (len str) u0) (<= (len str) max-string-length))
)

(define-private (is-valid-verification-standard (standard (string-ascii 50)))
  (and 
    (> (len standard) u0) 
    (<= (len standard) max-standard-length)
    (is-some (map-get? supported-standards { standard: standard }))
  )
)

(define-private (is-standard-active (standard (string-ascii 50)))
  (match (map-get? supported-standards { standard: standard })
    standard-info (get is-active standard-info)
    false
  )
)

(define-private (is-valid-vintage-year (year uint))
  (and (>= year min-vintage-year) (<= year max-vintage-year))
)

(define-private (is-valid-fee (fee uint))
  (<= fee max-fee)
)

(define-private (is-valid-methodology (methodology (string-ascii 100)))
  (and (> (len methodology) u0) (<= (len methodology) max-string-length))
)

(define-private (can-verifier-use-standard (verifier principal) (standard (string-ascii 50)))
  (match (map-get? verifier-status { verifier: verifier })
    verifier-info 
      (and 
        (get is-authorized verifier-info)
        (is-some (index-of (get authorized-standards verifier-info) standard))
      )
    false
  )
)

;; Public Functions

;; Issue new carbon credits with methodology support
(define-public (issue-carbon-credits 
  (project-name (string-ascii 100))
  (verification-standard (string-ascii 50))
  (vintage-year uint)
  (total-credits uint)
  (price-per-credit uint)
  (methodology (string-ascii 100)))
  (let (
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
  )
    (asserts! (can-verifier-use-standard tx-sender verification-standard) err-not-authorized)
    (asserts! (> total-credits u0) err-invalid-amount)
    (asserts! (> price-per-credit u0) err-invalid-price)
    (asserts! (is-valid-string project-name) err-invalid-string)
    (asserts! (is-valid-verification-standard verification-standard) err-invalid-standard)
    (asserts! (is-standard-active verification-standard) err-standard-not-supported)
    (asserts! (is-valid-vintage-year vintage-year) err-invalid-year)
    (asserts! (is-valid-methodology methodology) err-invalid-string)
    
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
        created-at: current-block,
        methodology: methodology
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
    (asserts! (>= (get available-credits credit-info) amount) err-insufficient-balance)
    
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
    (asserts! (not (get is-retired credit-info)) err-credit-retired)
    
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

;; Admin function to authorize verifiers with specific standards
(define-public (authorize-verifier (verifier principal) (standards (list 10 (string-ascii 50))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (is-eq verifier tx-sender)) err-invalid-principal)
    (asserts! (> (len standards) u0) err-invalid-standard)
    
    ;; Validate all standards are supported
    (asserts! (fold validate-standard-in-list standards true) err-standard-not-supported)
    
    (map-set verifier-status 
      { verifier: verifier } 
      { 
        is-authorized: true,
        authorized-standards: standards
      })
    (ok true)
  )
)

;; Helper function for validating standards in list
(define-private (validate-standard-in-list (standard (string-ascii 50)) (acc bool))
  (and acc (is-valid-verification-standard standard))
)

;; Admin function to add new verification standard
(define-public (add-verification-standard 
  (standard (string-ascii 50)) 
  (min-project-size uint)
  (description (string-ascii 200)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    (asserts! (> (len description) u0) err-invalid-string)
    (asserts! (<= (len description) max-description-length) err-invalid-string)
    (asserts! (> min-project-size u0) err-invalid-amount)
    (asserts! (is-none (map-get? supported-standards { standard: standard })) err-already-exists)
    
    (map-set supported-standards
      { standard: standard }
      {
        is-active: true,
        min-project-size: min-project-size,
        description: description
      })
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

;; Admin function to deactivate a verification standard
(define-public (deactivate-standard (standard (string-ascii 50)))
  (let (
    (standard-info (unwrap! (map-get? supported-standards { standard: standard }) err-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    
    (map-set supported-standards
      { standard: standard }
      (merge standard-info { is-active: false }))
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
  (match (map-get? verifier-status { verifier: verifier })
    verifier-info (get is-authorized verifier-info)
    false
  )
)

(define-read-only (get-verifier-standards (verifier principal))
  (match (map-get? verifier-status { verifier: verifier })
    verifier-info (some (get authorized-standards verifier-info))
    none
  )
)

(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

(define-read-only (get-next-credit-id)
  (var-get next-credit-id)
)

(define-read-only (get-supported-standard-info (standard (string-ascii 50)))
  (begin
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    (ok (map-get? supported-standards { standard: standard }))
  )
)

(define-read-only (is-standard-supported (standard (string-ascii 50)))
  (begin
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    (ok (is-some (map-get? supported-standards { standard: standard })))
  )
)

(define-read-only (get-credits-by-standard (standard (string-ascii 50)))
  (begin
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    ;; This is a simplified version - in a real implementation, 
    ;; you might want to use a separate map to track credits by standard
    (ok "Use external indexing for this query")
  )
)