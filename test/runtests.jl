using TupleVectors
using Sobol
using Test
using TupleVectors: chainvec, unwrap
using MeasureTheory
using LinearAlgebra

@testset "TupleVectors.jl" begin
    ## Testing constructors
    w = randn(10)
    y = randn(10)
    nt = (w=w, y=y)
    A = TupleVector(nt)
    B = TupleVector(; w=w, y=y)
    @test A.w == B.w
    
    @test chainvec(3,5)[1] == 3


    x = randn(2,2)
    A = chainvec((x = x,),100);

    @test A.x[1] == x
    @test A[1].x == A.x[1]

    for i in 2:100
        A[i] = (x=randn(2,2),)
    end

    B = @with A begin
        (x = x' + x,)
    end

    C = @with B begin
        (eigs = eigvals!(x),)
    end

    using Sobol

    ω = SobolHypercube(2)

    πapprox = @with (;ω) 10000 begin
        x = rand(ω)
        y = rand(ω)
        val = x^2 + y^2 < 1 ? 4 : 0
        (;val)
    end

    @test mean(πapprox.val) ≈ π atol=0.1

end
