context('test FARS')

test_that("Test FARS filename function",{

    my_file <- make_filename(2013)

    expect_true(nchar(my_file)>0)
    expect_is(my_file,"character")
    expect_length(my_file,1)
    expect_equal(my_file, "accident_2013.csv.bz2")
})
