// SPDX-License-Identifier: BSD-3-Clause
// Copyright Contributors to the OpenColorIO Project.

#include <OpenColorIO/OpenColorIO.h>
#include <sstream>

namespace OCIO_NAMESPACE
{

Exception::Exception(const char * msg)
    :   std::runtime_error(msg)
{
}

Exception::Exception(const std::string& str)
	: std::runtime_error(str.c_str())
{

}

Exception::Exception(const std::ostringstream& ss)
    : std::runtime_error(ss.str().c_str())
{}

Exception::Exception(const std::stringstream& ss)
	: std::runtime_error(ss.str().c_str())
{}


Exception::Exception(const Exception & e)
    :   std::runtime_error(e)
{
}

Exception::~Exception()
{
}


ExceptionMissingFile::ExceptionMissingFile(const char * msg)
    :   Exception(msg)
{
}


ExceptionMissingFile::ExceptionMissingFile(const ExceptionMissingFile & e)
    :   Exception(e)
{
}

ExceptionMissingFile::~ExceptionMissingFile()
{
}

} // namespace OCIO_NAMESPACE

