test_that("concatenate_all_list_columns", {
  tbl <- dplyr::tibble(
    "cola" = list(c("a", "b"), "a", c("a", "c")),
    "colb" = c("a", "b", "c"),
    "colc" = c("a", "b", NA),
    "cold" = list(c("a", "b"), "a", NA),
    "colf" = list(c(NA, NA), NA, c("c", "a", NA)),
    "colg" = list(c("a", "b"), "a", NULL),
    "colh" = c(2018L, 2019L, 2020L),
    "coli" = c(1.0, 2.0, 3.0),
    "colj" = c(T,T,F),
    "colk" = factor("A", "B")
  )

  expected <- dplyr::tibble(
    "cola" = c("a | b", "a", "a | c"),
    "colb" = c("a", "b", "c"),
    "colc" = c("a", "b", NA),
    "cold" = c("a | b", "a", NA),
    "colf" = c(NA, NA, "a | c"),
    "colg" = c("a | b", "a", NA),
    "colh" = c(2018L, 2019L, 2020L),
    "coli" = c(1.0, 2.0, 3.0),
    "colj" = c(T,T,F),
    "colk" = factor("A", "B")
  )

  expect_equal(concatenate_all_list_columns(tbl), expected)

})


test_that("concatenate_list_columns", {
  tbl1 <- dplyr::tibble(
    "cola" = list(c("a", "b"), "a", c("a", "c")),
    "colb" = c("a", "b", "c"),
    "colc" = c("a", "b", NA),
    "cold" = list(c("a", "b"), "a", NA),
    "colf" = list(c(NA, NA), NA, c("c", "a", NA)),
    "colg" = list(c("a", "b"), "a", NULL)
  )
  col1 <- "cola"
  col2 <- "colb"
  col3 <- "colc"
  col4 <- "cold"
  col5 <- "colf"
  col6 <- "colg"

  res1 <- concatenate_list_columns(tbl1, col1)
  expect_equal(
    res1,
    dplyr::tibble(
      "cola" = c("a | b", "a", "a | c"),
      "colb" = c("a", "b", "c"),
      "colc" = c("a", "b", NA),
      "cold" = list(c("a", "b"), "a", NA),
      "colf" = list(c(NA, NA), NA, c("c", "a", NA)),
      "colg" = list(c("a", "b"), "a", NULL)
    )
  )

  res2 <- concatenate_list_columns(tbl1, col2)
  expect_equal(res2, tbl1)

  res3 <- concatenate_list_columns(tbl1, col3)
  expect_equal(res3, tbl1)

  res4 <- concatenate_list_columns(tbl1, col4)
  expect_equal(
    res4,
    dplyr::tibble(
      "cola" = list(c("a", "b"), "a", c("a", "c")),
      "colb" = c("a", "b", "c"),
      "colc" = c("a", "b", NA),
      "cold" = c("a | b", "a", NA),
      "colf" = list(c(NA, NA), NA, c("c", "a", NA)),
      "colg" = list(c("a", "b"), "a", NULL)
    )
  )

  res5 <- concatenate_list_columns(tbl1, col5)
  expect_equal(
    res5,
    dplyr::tibble(
      "cola" = list(c("a", "b"), "a", c("a", "c")),
      "colb" = c("a", "b", "c"),
      "colc" = c("a", "b", NA),
      "cold" = list(c("a", "b"), "a", NA),
      "colf" = c(NA, NA, "a | c"),
      "colg" = list(c("a", "b"), "a", NULL)
    )
  )

  res6 <- concatenate_list_columns(tbl1, col6)
  expect_equal(
    res6,
    dplyr::tibble(
      "cola" = list(c("a", "b"), "a", c("a", "c")),
      "colb" = c("a", "b", "c"),
      "colc" = c("a", "b", NA),
      "cold" = list(c("a", "b"), "a", NA),
      "colf" = list(c(NA, NA), NA, c("c", "a", NA)),
      "colg" = c("a | b", "a", NA),
    )
  )

})
