# Yocto layer with various utility packages

This layer is maintained by [MicroTCA Tech Lab at DESY](https://techlab.desy.de/).

## Layer priority

This layer contains two recipes (`python3-bitstruct` and `python3-pybind11`)
which override the recipes in the `meta-python` layer. This is needed for the
`pyumaio` package available on other layers. Consequently, the priority of this
layer needs to be higher than the priority of the `meta-python` layer.
