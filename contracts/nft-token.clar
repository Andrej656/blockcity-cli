;; Define a non-fungible token named `simple-nft`
(define-non-fungible-token simple-nft uint)

;; Metadata map for NFTs
(define-map nft-metadata
  {nft-id: uint}
  {name: (string-utf8 50), description: (string-utf8 255), uri: (string-utf8 255)})

;; Contract owner for access control
(define-constant contract-owner tx-sender)

;; Trait definition for marketplace interaction
(define-trait nft-trait
  (
    (is-owner (nft-id uint) (owner principal) -> (response bool uint))
    (transfer (nft-id uint) (from principal) (to principal) -> (response bool uint))
  )
)

;; Minting a new NFT with metadata
(define-public (mint-nft (recipient principal) (nft-id uint) (name (string-utf8 50)) (description (string-utf8 255)) (uri (string-utf8 255)))
  (begin
    ;; Only the contract owner can mint new NFTs
    (if (is-eq tx-sender contract-owner)
      (match (nft-mint? simple-nft nft-id recipient)
        success 
        (begin
          (map-insert nft-metadata {nft-id: nft-id} {name: name, description: description, uri: uri})
          (ok success))
        error (err error))
      (err "Unauthorized"))))

;; Implementing the trait functions
(impl-trait .nft-token.nft-trait)

;; Check if a principal owns an NFT
(define-read-only (is-owner (nft-id uint) (owner principal))
  (ok (is-eq owner (nft-get-owner? simple-nft nft-id))))

;; Transfer an NFT from one principal to another
(define-public (transfer (nft-id uint) (from principal) (to principal))
  (begin
    (if (is-eq from tx-sender)
      (begin
        (match (nft-transfer? simple-nft nft-id from to)
          success (ok true)
          error (err error)))
      (err "Caller is not the owner"))))

;; Read-only function to fetch NFT metadata
(define-read-only (get-nft-metadata (nft-id uint))
  (map-get? nft-metadata {nft-id: nft-id}))
