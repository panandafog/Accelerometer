//
//  MeasurementsAxesView.swift
//  Accelerometer
//
//  Created by Andrey on 21.06.2022.
//

import SwiftUI

struct MeasurementsAxesView: View {
    @Binding var axes: Axes?
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("x")
                        .foregroundColor(.secondary)
                    Text("y")
                        .foregroundColor(.secondary)
                    Text("z")
                        .foregroundColor(.secondary)
                    Text("vector")
                        .foregroundColor(.secondary)
                }.padding([.trailing])
                VStack {
                    HeaderView()
                        .padding([.bottom])
                    VStack {
                        LevelView(
                            value: .init(get: {
                                axes?.properties.x
                            }, set: { value in
                            }),
                            max: .init(
                                get: {
                                    axes?.properties.maxX
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.properties.minX
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                        LevelView(
                            value: .init(get: {
                                axes?.properties.y
                            }, set: { value in
                            }),
                            max: .init(
                                get: {
                                    axes?.properties.maxY
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.properties.minY
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                        LevelView(
                            value: .init(get: {
                                axes?.properties.z
                            }, set: { value in
                            }),
                            max: .init(
                                get: {
                                    axes?.properties.maxZ
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.properties.minZ
                                },
                                set: { value in
                                    
                                }
                            )
                        )
                        LevelView(
                            value: .init(get: {
                                axes?.properties.vector
                            }, set: { value in
                                
                            }),
                            max: .init(
                                get: {
                                    axes?.properties.maxV
                                },
                                set: { value in
                                    
                                }
                            ),
                            min: .init(
                                get: {
                                    axes?.properties.minV
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
    }
}

struct MeasurementsAxesView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementsAxesView(axes: .init(get: {
            Axes(displayableAbsMax: 1.0)
        }, set: { _ in
            
        }))
    }
}
