//
//  DiagramView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct DiagramView: View {
    @Binding var axes: Measurer.Axes?
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("x")
                    Text("y")
                    Text("z")
                    Text("vector")
                }.padding([.trailing])
                VStack {
                    HeaderView()
                        .padding([.bottom])
                    //                        Rectangle()
                    //                            .fill(Color.accentColor)
                    VStack {
                        LevelView(
                            value: .init(get: {
                                axes?.x
                            }, set: { value in
                            }),
                            max: .init(
                                get: {
                                    axes?.maxX
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.minX
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                        LevelView(
                            value: .init(get: {
                                axes?.y
                            }, set: { value in
                            }),
                            max: .init(
                                get: {
                                    axes?.maxY
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.minY
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                        LevelView(
                            value: .init(get: {
                                axes?.z
                            }, set: { value in
                            }),
                            max: .init(
                                get: {
                                    axes?.maxZ
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.minZ
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                        LevelView(
                            value: .init(get: {
                                axes?.vector
                            }, set: { value in
                                
                            }),
                            max: .init(
                                get: {
                                    axes?.maxV
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.minV
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.background)
        .cornerRadius(5)
    }
}

struct DiagramView_Previews: PreviewProvider {
    static var previews: some View {
        DiagramView(axes: .init(get: {
            Measurer.Axes(x: 1, y: 2, z: 3)
        }, set: { _ in
            
        }))
    }
}
