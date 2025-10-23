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
(define-constant err-batch-too-large (err u114))
(define-constant err-batch-empty (err u115))
(define-constant err-batch-validation-failed (err u116))
(define-constant err-invalid-multiplier (err u117))
(define-constant err-price-floor-exceeded (err u118))

;; Validation constants
(define-constant max-fee u1000) ;; Maximum 10% fee
(define-constant min-vintage-year u1990)
(define-constant max-vintage-year u2050)
(define-constant max-string-length u100)
(define-constant max-standard-length u50)
(define-constant max-description-length u200)
(define-constant max-batch-size u20) ;; Maximum items per batch operation

;; Dynamic pricing constants
(define-constant base-multiplier u10000) ;; 100% in basis points
(define-constant max-price-multiplier u50000) ;; 500% maximum
(define-constant min-price-multiplier u5000) ;; 50% minimum
(define-constant demand-threshold-high u8000) ;; 80% utilization
(define-constant demand-threshold-low u2000) ;; 20% utilization
(define-constant price-adjustment-rate u500) ;; 5% adjustment per threshold

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
(define-data-var next-batch-id uint u1)
(define-data-var dynamic-pricing-enabled bool true)

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
    base-price: uint,
    price-floor: uint,
    is-verified: bool,
    is-retired: bool,
    created-at: uint,
    methodology: (string-ascii 100),
    total-sold: uint,
    last-price-update: uint
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

(define-map batch-operations
  { batch-id: uint }
  {
    operation-type: (string-ascii 20),
    operator: principal,
    timestamp: uint,
    items-count: uint,
    total-credits: uint,
    success-count: uint
  }
)

(define-map price-history
  { credit-id: uint, timestamp: uint }
  {
    price: uint,
    utilization-rate: uint,
    demand-multiplier: uint
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

;; Dynamic pricing calculation functions
(define-private (calculate-utilization-rate (available uint) (total uint))
  (if (is-eq total u0)
    u0
    (/ (* (- total available) u10000) total)
  )
)

(define-private (calculate-demand-multiplier (utilization-rate uint))
  (if (>= utilization-rate demand-threshold-high)
    ;; High demand: increase price
    (let ((excess (- utilization-rate demand-threshold-high)))
      (+ base-multiplier (/ (* excess price-adjustment-rate) u1000))
    )
    (if (<= utilization-rate demand-threshold-low)
      ;; Low demand: decrease price
      (let ((deficit (- demand-threshold-low utilization-rate)))
        (- base-multiplier (/ (* deficit price-adjustment-rate) u1000))
      )
      ;; Normal demand: base price
      base-multiplier
    )
  )
)

(define-private (calculate-dynamic-price (base-price uint) (price-floor uint) (utilization-rate uint))
  (let (
    (demand-multiplier (calculate-demand-multiplier utilization-rate))
    (capped-multiplier (if (> demand-multiplier max-price-multiplier)
                          max-price-multiplier
                          (if (< demand-multiplier min-price-multiplier)
                            min-price-multiplier
                            demand-multiplier)))
    (calculated-price (/ (* base-price capped-multiplier) base-multiplier))
  )
    (if (< calculated-price price-floor)
      price-floor
      calculated-price
    )
  )
)

(define-private (get-current-price (credit-id uint))
  (match (map-get? carbon-credits { credit-id: credit-id })
    credit-info
      (if (var-get dynamic-pricing-enabled)
        (let (
          (utilization-rate (calculate-utilization-rate 
                              (get available-credits credit-info)
                              (get total-credits credit-info)))
          (dynamic-price (calculate-dynamic-price 
                           (get base-price credit-info)
                           (get price-floor credit-info)
                           utilization-rate))
        )
          dynamic-price
        )
        (get base-price credit-info)
      )
    u0
  )
)

(define-private (record-price-history (credit-id uint) (price uint) (utilization-rate uint) (demand-multiplier uint))
  (let (
    (current-block stacks-block-height)
  )
    (map-set price-history
      { credit-id: credit-id, timestamp: current-block }
      {
        price: price,
        utilization-rate: utilization-rate,
        demand-multiplier: demand-multiplier
      }
    )
  )
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

(define-private (is-valid-batch-size (batch-size uint))
  (and (> batch-size u0) (<= batch-size max-batch-size))
)

(define-private (is-valid-price-multiplier (multiplier uint))
  (and (>= multiplier min-price-multiplier) (<= multiplier max-price-multiplier))
)

;; Batch credit issuance helper
(define-private (issue-single-credit 
  (item {
    project-name: (string-ascii 100),
    verification-standard: (string-ascii 50),
    vintage-year: uint,
    total-credits: uint,
    base-price: uint,
    price-floor: uint,
    methodology: (string-ascii 100)
  })
  (acc { success-count: uint, total-credits: uint, last-error: (optional uint) }))
  (let (
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
    (project-name (get project-name item))
    (verification-standard (get verification-standard item))
    (vintage-year (get vintage-year item))
    (total-credits (get total-credits item))
    (base-price (get base-price item))
    (price-floor (get price-floor item))
    (methodology (get methodology item))
  )
    (if (and 
          (can-verifier-use-standard tx-sender verification-standard)
          (> total-credits u0)
          (> base-price u0)
          (> price-floor u0)
          (<= price-floor base-price)
          (is-valid-string project-name)
          (is-valid-verification-standard verification-standard)
          (is-standard-active verification-standard)
          (is-valid-vintage-year vintage-year)
          (is-valid-methodology methodology))
      (begin
        (map-set carbon-credits 
          { credit-id: credit-id }
          {
            issuer: tx-sender,
            project-name: project-name,
            verification-standard: verification-standard,
            vintage-year: vintage-year,
            total-credits: total-credits,
            available-credits: total-credits,
            base-price: base-price,
            price-floor: price-floor,
            is-verified: true,
            is-retired: false,
            created-at: current-block,
            methodology: methodology,
            total-sold: u0,
            last-price-update: current-block
          }
        )
        (set-credit-balance tx-sender credit-id total-credits)
        (var-set next-credit-id (+ credit-id u1))
        {
          success-count: (+ (get success-count acc) u1),
          total-credits: (+ (get total-credits acc) total-credits),
          last-error: none
        }
      )
      {
        success-count: (get success-count acc),
        total-credits: (get total-credits acc),
        last-error: (some u116)
      }
    )
  )
)

;; Batch retirement helper
(define-private (retire-single-credit 
  (item { credit-id: uint, amount: uint })
  (acc { success-count: uint, total-credits: uint, last-error: (optional uint) }))
  (let (
    (credit-id (get credit-id item))
    (amount (get amount item))
    (owner-balance (get-credit-balance tx-sender credit-id))
  )
    (match (map-get? carbon-credits { credit-id: credit-id })
      credit-info
        (if (and 
              (> amount u0)
              (>= owner-balance amount)
              (not (get is-retired credit-info)))
          (begin
            ;; Reduce owner balance
            (set-credit-balance tx-sender credit-id (- owner-balance amount))
            
            ;; Update available credits
            (map-set carbon-credits 
              { credit-id: credit-id }
              (merge credit-info { available-credits: (- (get available-credits credit-info) amount) })
            )
            
            {
              success-count: (+ (get success-count acc) u1),
              total-credits: (+ (get total-credits acc) amount),
              last-error: none
            }
          )
          {
            success-count: (get success-count acc),
            total-credits: (get total-credits acc),
            last-error: (some u102)
          }
        )
      {
        success-count: (get success-count acc),
        total-credits: (get total-credits acc),
        last-error: (some u101)
      }
    )
  )
)

;; Helper function for validating standards in list
(define-private (validate-standard-in-list (standard (string-ascii 50)) (acc bool))
  (and acc (is-valid-verification-standard standard))
)

;; Public Functions

;; Issue new carbon credits with dynamic pricing support
(define-public (issue-carbon-credits 
  (project-name (string-ascii 100))
  (verification-standard (string-ascii 50))
  (vintage-year uint)
  (total-credits uint)
  (base-price uint)
  (price-floor uint)
  (methodology (string-ascii 100)))
  (let (
    (credit-id (var-get next-credit-id))
    (current-block stacks-block-height)
  )
    (asserts! (can-verifier-use-standard tx-sender verification-standard) err-not-authorized)
    (asserts! (> total-credits u0) err-invalid-amount)
    (asserts! (> base-price u0) err-invalid-price)
    (asserts! (> price-floor u0) err-invalid-price)
    (asserts! (<= price-floor base-price) err-price-floor-exceeded)
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
        base-price: base-price,
        price-floor: price-floor,
        is-verified: true,
        is-retired: false,
        created-at: current-block,
        methodology: methodology,
        total-sold: u0,
        last-price-update: current-block
      }
    )
    
    (set-credit-balance tx-sender credit-id total-credits)
    (var-set next-credit-id (+ credit-id u1))
    
    (ok credit-id)
  )
)

;; Batch issue carbon credits
(define-public (batch-issue-carbon-credits 
  (credits-list (list 20 {
    project-name: (string-ascii 100),
    verification-standard: (string-ascii 50),
    vintage-year: uint,
    total-credits: uint,
    base-price: uint,
    price-floor: uint,
    methodology: (string-ascii 100)
  })))
  (let (
    (batch-size (len credits-list))
    (batch-id (var-get next-batch-id))
    (result (fold issue-single-credit credits-list 
                   { success-count: u0, total-credits: u0, last-error: none }))
  )
    (asserts! (is-valid-batch-size batch-size) err-batch-empty)
    (asserts! (is-none (get last-error result)) err-batch-validation-failed)
    
    ;; Record batch operation
    (map-set batch-operations
      { batch-id: batch-id }
      {
        operation-type: "ISSUE",
        operator: tx-sender,
        timestamp: stacks-block-height,
        items-count: batch-size,
        total-credits: (get total-credits result),
        success-count: (get success-count result)
      }
    )
    
    (var-set next-batch-id (+ batch-id u1))
    
    (ok {
      batch-id: batch-id,
      success-count: (get success-count result),
      total-credits: (get total-credits result)
    })
  )
)

;; Purchase carbon credits with dynamic pricing
(define-public (purchase-credits (credit-id uint) (amount uint))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-not-found))
    (seller (get issuer credit-info))
    (seller-balance (get-credit-balance seller credit-id))
    (current-price (get-current-price credit-id))
    (utilization-rate (calculate-utilization-rate 
                        (get available-credits credit-info)
                        (get total-credits credit-info)))
    (demand-multiplier (calculate-demand-multiplier utilization-rate))
    (total-cost (* amount current-price))
    (fee-amount (calculate-platform-fee total-cost))
    (seller-amount (- total-cost fee-amount))
    (buyer-current-balance (get-credit-balance tx-sender credit-id))
    (transaction-id (var-get next-transaction-id))
    (current-block stacks-block-height)
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> current-price u0) err-invalid-price)
    (asserts! (>= seller-balance amount) err-insufficient-balance)
    (asserts! (not (get is-retired credit-info)) err-credit-retired)
    (asserts! (>= (get available-credits credit-info) amount) err-insufficient-balance)
    
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? seller-amount tx-sender seller))
    
    ;; Transfer platform fee to contract owner
    (try! (stx-transfer? fee-amount tx-sender contract-owner))
    
    ;; Update seller balance
    (set-credit-balance seller credit-id (- seller-balance amount))
    
    ;; Update buyer balance
    (set-credit-balance tx-sender credit-id (+ buyer-current-balance amount))
    
    ;; Update credit info
    (map-set carbon-credits 
      { credit-id: credit-id }
      (merge credit-info { 
        available-credits: (- (get available-credits credit-info) amount),
        total-sold: (+ (get total-sold credit-info) amount),
        last-price-update: current-block
      })
    )
    
    ;; Record price history
    (record-price-history credit-id current-price utilization-rate demand-multiplier)
    
    ;; Record transaction
    (map-set credit-transactions
      { transaction-id: transaction-id }
      {
        credit-id: credit-id,
        seller: seller,
        buyer: tx-sender,
        amount: amount,
        price: current-price,
        timestamp: current-block
      }
    )
    
    (var-set next-transaction-id (+ transaction-id u1))
    
    (ok { transaction-id: transaction-id, price: current-price })
  )
)

;; Retire carbon credits
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

;; Batch retire carbon credits
(define-public (batch-retire-credits 
  (retirement-list (list 20 { credit-id: uint, amount: uint })))
  (let (
    (batch-size (len retirement-list))
    (batch-id (var-get next-batch-id))
    (result (fold retire-single-credit retirement-list 
                   { success-count: u0, total-credits: u0, last-error: none }))
  )
    (asserts! (is-valid-batch-size batch-size) err-batch-empty)
    (asserts! (is-none (get last-error result)) err-batch-validation-failed)
    
    ;; Record batch operation
    (map-set batch-operations
      { batch-id: batch-id }
      {
        operation-type: "RETIRE",
        operator: tx-sender,
        timestamp: stacks-block-height,
        items-count: batch-size,
        total-credits: (get total-credits result),
        success-count: (get success-count result)
      }
    )
    
    (var-set next-batch-id (+ batch-id u1))
    
    (ok {
      batch-id: batch-id,
      success-count: (get success-count result),
      total-credits: (get total-credits result)
    })
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

;; Admin function to toggle dynamic pricing
(define-public (toggle-dynamic-pricing (enabled bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set dynamic-pricing-enabled enabled)
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

(define-read-only (is-standard-supported (standard (string-ascii 50)))
  (begin
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    (ok (is-some (map-get? supported-standards { standard: standard })))
  )
)

(define-read-only (get-credit-info (credit-id uint))
  (map-get? carbon-credits { credit-id: credit-id })
)

(define-read-only (get-current-credit-price (credit-id uint))
  (ok (get-current-price credit-id))
)

(define-read-only (get-price-components (credit-id uint))
  (match (map-get? carbon-credits { credit-id: credit-id })
    credit-info
      (let (
        (utilization-rate (calculate-utilization-rate 
                            (get available-credits credit-info)
                            (get total-credits credit-info)))
        (demand-multiplier (calculate-demand-multiplier utilization-rate))
        (current-price (if (var-get dynamic-pricing-enabled)
                          (calculate-dynamic-price 
                            (get base-price credit-info)
                            (get price-floor credit-info)
                            utilization-rate)
                          (get base-price credit-info)))
      )
        (ok {
          base-price: (get base-price credit-info),
          price-floor: (get price-floor credit-info),
          current-price: current-price,
          utilization-rate: utilization-rate,
          demand-multiplier: demand-multiplier,
          dynamic-pricing-enabled: (var-get dynamic-pricing-enabled)
        })
      )
    err-not-found
  )
)

(define-read-only (get-price-history-at (credit-id uint) (timestamp uint))
  (map-get? price-history { credit-id: credit-id, timestamp: timestamp })
)

(define-read-only (get-user-balance (owner principal) (credit-id uint))
  (get-credit-balance owner credit-id)
)

(define-read-only (get-transaction-info (transaction-id uint))
  (map-get? credit-transactions { transaction-id: transaction-id })
)

(define-read-only (get-batch-info (batch-id uint))
  (map-get? batch-operations { batch-id: batch-id })
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

(define-read-only (is-dynamic-pricing-enabled)
  (var-get dynamic-pricing-enabled)
)

(define-read-only (get-next-credit-id)
  (var-get next-credit-id)
)

(define-read-only (get-next-batch-id)
  (var-get next-batch-id)
)

(define-read-only (get-supported-standard-info (standard (string-ascii 50)))
  (begin
    (asserts! (> (len standard) u0) err-invalid-string)
    (asserts! (<= (len standard) max-standard-length) err-invalid-string)
    (ok (map-get? supported-standards { standard: standard }))
  )
)