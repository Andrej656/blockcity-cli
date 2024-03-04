;; Assume a simple NFT token contract is already deployed and has this trait
(use-trait nft-trait .nft-token.nft-trait)

(define-map listings
  {nft-id: uint}
  {owner: principal, price: uint})

(define-public (list-nft (nft-id uint) (price uint))
  (let ((owner (as-contract tx-sender)))
    (begin
      ;; Ensure the NFT is owned by the seller
      (asserts! (nft-get-owner? .nft-token nft-id) (is-eq owner (ok tx-sender)))
      ;; Add listing to the map
      (map-insert listings {nft-id: nft-id} {owner: owner, price: price})
      (ok true))))

(define-public (buy-nft (nft-id uint))
  (let ((listing (map-get? listings {nft-id: nft-id})))
    (match listing
      listing-data
      (let ((seller (get owner listing-data))
            (price (get price listing-data)))
        ;; Transfer STX from buyer to seller
        (try! (stx-transfer? price tx-sender seller))
        ;; Transfer NFT ownership from seller to buyer
        (try! (contract-call? .nft-token transfer nft-id seller tx-sender))
        ;; Remove listing
        (map-delete listings {nft-id: nft-id})
        (ok true))
      (err "NFT not listed"))))

(define-public (cancel-listing (nft-id uint))
  (let ((listing (map-get? listings {nft-id: nft-id})))
    (match listing
      listing-data
      (begin
        ;; Ensure
the caller is the owner of the listing
(asserts! (is-eq (get owner listing-data) tx-sender) (err "Not the owner of the listing"))
;; Remove the listing
(map-delete listings {nft-id: nft-id})
(ok true))
(err "Listing does not exist"))))

(define-public (update-listing (nft-id uint) (new-price uint))
(let ((listing (map-get? listings {nft-id: nft-id})))
(match listing
listing-data
(begin
;; Ensure the caller is the owner of the listing
(asserts! (is-eq (get owner listing-data) tx-sender) (err "Not the owner of the listing"))
;; Update the listing with the new price
(map-set listings {nft-id: nft-id} {owner: (get owner listing-data), price: new-price})
(ok true))
(err "Listing does not exist"))))