fn main(
    n: Field,
    range_min: pub Field,
    range_max: pub Field,
    hash_result: pub [u8; 32]
) {
    let n_as_u64 = n as u64;
    let range_min_as_u64 = range_min as u64;
    let range_max_as_u64 = range_max as u64;
    
    assert(n_as_u64 >= range_min_as_u64);
    assert(n_as_u64 <= range_max_as_u64);
    
    let mut n_bytes = [0; 32];
    n_bytes[0] = n_as_u64 as u8;
    
    let computed_hash = std::hash::sha256(n_bytes);
    
    assert(computed_hash == hash_result);
}
