# Changelog

## [Unreleased]

### Changed

- **Breaking**: `XArrayDataArray` reads its data, attributes and coordinates once, at construction. `dims(var, i)` is a `DataVariable` of the xarray coordinate (a matrix for time-varying bins), not an `XArrayDataArray`.

### Fixed

- `tdimnum` of a variable without a `time` dimension is `nothing`, not its last dimension.

## [0.2.0] - 2025-10-16

### Added

- Added `PySPEDASSchema` for `pyspedas` CDF/VATT metadata
- Added `XArrayDataArray` coordinate and dimension support for `xarray.DataArray`
  values, including multidimensional coordinates.

### Changed

- **Breaking**: `get_data` now returns `XArrayDataArray` instead of the
  previous `TplotVariable` structure.
- `DimensionalData.jl` is now an optional weak dependency instead of a hard
  dependency.
