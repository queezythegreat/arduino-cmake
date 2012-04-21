// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: t -*-

// Copyright 2010 Michael Smith, all rights reserved.

//	This library is free software; you can redistribute it and / or
//	modify it under the terms of the GNU Lesser General Public
//	License as published by the Free Software Foundation; either
//	version 2.1 of the License, or (at your option) any later version.

// Inspired by:
/****************************************
 * 3D Vector Classes
 * By Bill Perone (billperone@yahoo.com)
 */

//
// 3x3 matrix implementation.
//
// Note that the matrix is organised in row-normal form (the same as
// applies to array indexing).
//
// In addition to the template, this header defines the following types:
//
// Matrix3i		3x3 matrix of signed integers
// Matrix3ui	3x3 matrix of unsigned integers
// Matrix3l		3x3 matrix of signed longs
// Matrix3ul	3x3 matrix of unsigned longs
// Matrix3f		3x3 matrix of signed floats
//

#ifndef MATRIX3_H
#define MATRIX3_H

#include "vector3.h"

// 3x3 matrix with elements of type T
template <typename T>
class Matrix3 {
public:

	// Vectors comprising the rows of the matrix
	Vector3<T>	a, b, c;

	// trivial ctor
	// note that the Vector3 ctor will zero the vector elements
	Matrix3<T>() {}

	// setting ctor
	Matrix3<T>(const Vector3<T> a0, const Vector3<T> b0, const Vector3<T> c0): a(a0), b(b0), c(c0) {}

	// setting ctor
	Matrix3<T>(const T ax, const T ay, const T az, const T bx, const T by, const T bz, const T cx, const T cy, const T cz): a(ax,ay,az), b(bx,by,bz), c(cx,cy,cz) {}

	// function call operator
	void operator () (const Vector3<T> a0, const Vector3<T> b0, const Vector3<T> c0)
	{	a = a0; b = b0; c = c0;  }

	// test for equality
	bool operator == (const Matrix3<T> &m)
	{	return (a==m.a && b==m.b && c==m.c);	}

	// test for inequality
	bool operator != (const Matrix3<T> &m)
	{	return (a!=m.a || b!=m.b || c!=m.c);	}

	// negation
	Matrix3<T> operator - (void) const
	{	return Matrix3<T>(-a,-b,-c);	}

	// addition
	Matrix3<T> operator + (const Matrix3<T> &m) const
	{   return Matrix3<T>(a+m.a, b+m.b, c+m.c);	 }
	Matrix3<T> &operator += (const Matrix3<T> &m)
	{	return *this = *this + m;	}

	// subtraction
	Matrix3<T> operator - (const Matrix3<T> &m) const
	{   return Matrix3<T>(a-m.a, b-m.b, c-m.c);	 }
	Matrix3<T> &operator -= (const Matrix3<T> &m)
	{	return *this = *this - m;	}

	// uniform scaling
	Matrix3<T> operator * (const T num) const
	{	return Matrix3<T>(a*num, b*num, c*num);	}
	Matrix3<T> &operator *= (const T num)
	{	return *this = *this * num;	}
	 Matrix3<T> operator / (const T num) const
	{	return Matrix3<T>(a/num, b/num, c/num);	}
	Matrix3<T> &operator /= (const T num)
	{	return *this = *this / num;	}

	// multiplication by a vector
	Vector3<T> operator *(const Vector3<T> &v) const;

	// multiplication of transpose by a vector
	Vector3<T> mul_transpose(const Vector3<T> &v) const;

	// multiplication by another Matrix3<T>
	Matrix3<T> operator *(const Matrix3<T> &m) const;

	Matrix3<T> &operator *=(const Matrix3<T> &m)
	{	return *this = *this * m;	}

	// transpose the matrix
	Matrix3<T> transposed(void) const
	{
		return Matrix3<T>(Vector3<T>(a.x, b.x, c.x),
						  Vector3<T>(a.y, b.y, c.y),
						  Vector3<T>(a.z, b.z, c.z));
	}
	Matrix3<T> transpose(void)
	{	return *this = transposed();	}

	// zero the matrix
	void zero(void) {
		a.x = a.y = a.z = 0;
		b.x = b.y = b.z = 0;
		c.x = c.y = c.z = 0;
	}

	// setup the identity matrix
	void identity(void) {
		a.x = b.y = c.z = 1;
		a.y = a.z = 0;
		b.x = b.z = 0;
		c.x = c.y = 0;
	}

	// check if any elements are NAN
	bool is_nan(void)
		{   return a.is_nan() || b.is_nan() || c.is_nan(); }

	// fill in the matrix with a standard rotation
	void rotation(enum Rotation rotation);

    // create a rotation matrix from Euler angles
	void from_euler(float roll, float pitch, float yaw);

    // create eulers from a rotation matrix
	void to_euler(float *roll, float *pitch, float *yaw);

    // apply an additional rotation from a body frame gyro vector
    // to a rotation matrix.
	void rotate(const Vector3<T> &g);
};

typedef Matrix3<int16_t>		Matrix3i;
typedef Matrix3<uint16_t>		Matrix3ui;
typedef Matrix3<int32_t>		Matrix3l;
typedef Matrix3<uint32_t>		Matrix3ul;
typedef Matrix3<float>			Matrix3f;

#endif // MATRIX3_H
