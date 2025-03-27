;; quality-verification.clar
;; Tracks testing for safety and characteristics

(define-data-var next-test-id uint u0)

(define-map quality-tests
  { test-id: uint }
  {
    producer-id: uint,
    cheese-type: (string-utf8 100),
    test-date: uint,
    safety-passed: bool,
    flavor-score: uint,
    texture-score: uint,
    notes: (string-utf8 200)
  }
)

(define-public (record-quality-test
    (producer-id uint)
    (cheese-type (string-utf8 100))
    (test-date uint)
    (safety-passed bool)
    (flavor-score uint)
    (texture-score uint)
    (notes (string-utf8 200)))
  (let
    ((new-id (var-get next-test-id)))
    (begin
      (asserts! (<= flavor-score u10) (err u3)) ;; Score must be 0-10
      (asserts! (<= texture-score u10) (err u4)) ;; Score must be 0-10
      (var-set next-test-id (+ new-id u1))
      (map-set quality-tests
        { test-id: new-id }
        {
          producer-id: producer-id,
          cheese-type: cheese-type,
          test-date: test-date,
          safety-passed: safety-passed,
          flavor-score: flavor-score,
          texture-score: texture-score,
          notes: notes
        }
      )
      (ok new-id)
    )
  )
)

(define-read-only (get-quality-test (test-id uint))
  (map-get? quality-tests { test-id: test-id })
)

(define-read-only (is-cheese-safe (test-id uint))
  (let
    ((test (map-get? quality-tests { test-id: test-id })))
    (if (is-some test)
      (get safety-passed (unwrap-panic test))
      false
    )
  )
)

(define-read-only (get-cheese-quality-score (test-id uint))
  (let
    ((test (map-get? quality-tests { test-id: test-id })))
    (if (is-some test)
      (let
        ((unwrapped (unwrap-panic test)))
        (+ (get flavor-score unwrapped) (get texture-score unwrapped))
      )
      u0
    )
  )
)
