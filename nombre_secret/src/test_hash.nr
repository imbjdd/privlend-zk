fn main(x: Field) -> [u8; 32] {
    let n = x as u64;
    let mut n_bytes = [0; 32];
    n_bytes[0] = n as u8;
    
    std::hash::sha256(n_bytes)
}

#[test]
fn test_hash() {
    let hash = main(7);
    std::println(hash);
} 