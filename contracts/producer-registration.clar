;; producer-registration.clar
;; Records details of artisanal cheesemakers

(define-data-var next-producer-id uint u0)

(define-map producers
  { producer-id: uint }
  {
    name: (string-utf8 100),
    location: (string-utf8 100),
    specialties: (string-utf8 200),
    active: bool
  }
)

(define-public (register-producer (name (string-utf8 100)) (location (string-utf8 100)) (specialties (string-utf8 200)))
  (let
    ((new-id (var-get next-producer-id)))
    (begin
      (var-set next-producer-id (+ new-id u1))
      (map-set producers { producer-id: new-id } { name: name, location: location, specialties: specialties, active: true })
      (ok new-id)
    )
  )
)

(define-public (update-producer-info
    (producer-id uint)
    (name (string-utf8 100))
    (location (string-utf8 100))
    (specialties (string-utf8 200)))
  (let
    ((producer (map-get? producers { producer-id: producer-id })))
    (if (is-some producer)
      (begin
        (map-set producers
          { producer-id: producer-id }
          {
            name: name,
            location: location,
            specialties: specialties,
            active: (get active (unwrap-panic producer))
          }
        )
        (ok true)
      )
      (err u1) ;; Producer not found
    )
  )
)

(define-public (set-producer-status (producer-id uint) (active bool))
  (let
    ((producer (map-get? producers { producer-id: producer-id })))
    (if (is-some producer)
      (begin
        (map-set producers
          { producer-id: producer-id }
          {
            name: (get name (unwrap-panic producer)),
            location: (get location (unwrap-panic producer)),
            specialties: (get specialties (unwrap-panic producer)),
            active: active
          }
        )
        (ok true)
      )
      (err u1) ;; Producer not found
    )
  )
)

(define-read-only (get-producer (producer-id uint))
  (map-get? producers { producer-id: producer-id })
)
