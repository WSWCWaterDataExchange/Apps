context("Map Tests")

test_that("Example Works", {
  
  state <- "Delaware" 
  unit_type <- "huc"
  year <- 2010
  plot_units <- get_state_spatial_units(state, unit_type, year)
  # run saveRds(...,...) to update the rds if this changes.
  expect_equal_to_reference(plot_units, "data/test_get_state_spatial_units_example.rds")
  
})