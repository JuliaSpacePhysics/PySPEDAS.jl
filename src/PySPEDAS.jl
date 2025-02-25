module PySPEDAS

using PythonCall

export tplot, mms

tplot(args...) = PythonCall.pyimport("pyspedas").tplot(args...)
mms = PythonCall.pyimport("pyspedas").mms

end
