//
//  LoginButtonAnimation.swift
//  Fantasticoh!
//
//  Created by Shubham on 7/28/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
import UIKit

class LoginButtonAnimation {
    
    
    class func fbButtonAnimation(button: UIButton, btnConstraint: NSLayoutConstraint, constraintVal : CGFloat, googleBtn: UIButton, googleBtnCons: NSLayoutConstraint, skipBtn: UIButton, view: UIView) {
        
        button.isHidden = false
        UIView.animate(withDuration: 2.6, animations: {
            
            btnConstraint.constant = 0
            UIView.animate(withDuration: 0.52, animations: {
                button.alpha = 0.01
                btnConstraint.constant = constraintVal * 2
                view.layoutIfNeeded()
                UIView.animate(withDuration: 0.52, animations: {
                    button.alpha = 0.03
                    btnConstraint.constant = constraintVal * 4
                    view.layoutIfNeeded()
                    UIView.animate(withDuration: 0.52, animations: {
                        button.alpha = 0.05
                        btnConstraint.constant = constraintVal * 6
                        view.layoutIfNeeded()
                        UIView.animate(withDuration: 0.52, animations: {
                            button.alpha = 0.07
                            btnConstraint.constant = constraintVal * 8
                            view.layoutIfNeeded()
                            UIView.animate(withDuration: 0.52, animations: {
                                
                                button.alpha = 1
                                btnConstraint.constant = constraintVal * 10
                                view.layoutIfNeeded()
                                
                                self.googleBtnAnimation(button: googleBtn, btnConstraint: googleBtnCons, constraintVal: 6.5, view: view, skipbtn: skipBtn)
                            }) { (animationFinished: Bool) in
                                
                            }
                            
                        }) { (animationFinished: Bool) in
                        }
                    }) { (animationFinished: Bool) in
                    }
                }) { (animationFinished: Bool) in
                }
            }) { (animationFinished: Bool) in
            }
        }) { (animationFinished: Bool) in
            
        }
        
    }
    
    
    class  func googleBtnAnimation(button: UIButton, btnConstraint: NSLayoutConstraint, constraintVal : CGFloat, view: UIView, skipbtn: UIButton) {
        
        button.isHidden = false
        
        
        UIView.animate(withDuration: 4.16, animations: {
            UIView.animate(withDuration: 0.52, animations: {
                UIView.animate(withDuration: 0.52, animations: {
                    UIView.animate(withDuration: 0.52, animations: {
                        UIView.animate(withDuration: 0.52, animations: {
                            button.alpha = 0.0
                            btnConstraint.constant = constraintVal * 2
                            view.layoutIfNeeded()
                            UIView.animate(withDuration: 0.52, animations: {
                                button.alpha = 0.00
                                btnConstraint.constant = constraintVal * 4
                                view.layoutIfNeeded()
                                UIView.animate(withDuration: 0.52, animations: {
                                    button.alpha = 0.00
                                    btnConstraint.constant = constraintVal * 6
                                    view.layoutIfNeeded()
                                    UIView.animate(withDuration: 0.52, animations: {
                                        button.alpha = 0.08
                                        btnConstraint.constant = constraintVal * 8
                                        view.layoutIfNeeded()
                                        UIView.animate(withDuration: 0.52, animations: {
                                            button.alpha = 0.5
                                            btnConstraint.constant = constraintVal * 10
                                            view.layoutIfNeeded()
                                        }) { (animationFinished: Bool) in
                                        }
                                        
                                    }) { (animationFinished: Bool) in
                                        skipbtn.isHidden = false
                                        self.skipBtnAnimation(button: skipbtn, view: view)
                                        UIView.animate(withDuration: 0.52, animations: {
                                            button.alpha = 0.2
                                            UIView.animate(withDuration: 0.52, animations: {
                                                button.alpha = 0.35
                                                UIView.animate(withDuration: 0.52, animations: {
                                                    button.alpha = 0.55
                                                    UIView.animate(withDuration: 0.52, animations: {
                                                        button.alpha = 0.75
                                                        UIView.animate(withDuration: 0.52, animations: {
                                                            button.alpha = 9
                                                        }) { (animationFinished: Bool) in
                                                            button.alpha = 1
                                                            
                                                        }
                                                    }) { (animationFinished: Bool) in
                                                    }
                                                }) { (animationFinished: Bool) in
                                                }
                                            }) { (animationFinished: Bool) in
                                            }
                                            
                                        }) { (animationFinished: Bool) in
                                        }
                                    }
                                }) { (animationFinished: Bool) in
                                }
                            }) { (animationFinished: Bool) in
                            }
                        }) { (animationFinished: Bool) in
                        }
                    }) { (animationFinished: Bool) in
                    }
                }) { (animationFinished: Bool) in
                }
            }) { (animationFinished: Bool) in
            }
        }) { (animationFinished: Bool) in
        }
        
    }
    
    class func skipBtnAnimation(button: UIButton, view: UIView)  {
        
        button.isHidden = false
        UIView.animate(withDuration: 2.6, animations: {
            UIView.animate(withDuration: 0.52, animations: {
                button.alpha = 0.01
                view.layoutIfNeeded()
                UIView.animate(withDuration: 0.52, animations: {
                    button.alpha = 0.03
                    view.layoutIfNeeded()
                    UIView.animate(withDuration: 0.52, animations: {
                        button.alpha = 0.05
                        view.layoutIfNeeded()
                        UIView.animate(withDuration: 0.52, animations: {
                            button.alpha = 0.07
                            view.layoutIfNeeded()
                            UIView.animate(withDuration: 0.52, animations: {
                                button.alpha = 1
                            }) { (animationFinished: Bool) in
                            }
                        }) { (animationFinished: Bool) in
                        }
                    }) { (animationFinished: Bool) in
                    }
                }) { (animationFinished: Bool) in
                }
            }) { (animationFinished: Bool) in
            }
        }) { (animationFinished: Bool) in
        }
    }
    
    
   
    /*
    //MARK : Animation Button in class LoginVC.
    // Use animaiton of given btn.
    private func fbButtonAnimation(button: UIButton, btnConstraint: NSLayoutConstraint, constraintVal : CGFloat) {
        
        button.isHidden = false
        UIView.animateWithDuration(2.6, animations: {
            
            btnConstraint.constant = 0
            UIView.animateWithDuration(0.52, animations: {
                button.alpha = 0.01
                btnConstraint.constant = constraintVal * 2
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(0.52, animations: {
                    button.alpha = 0.03
                    btnConstraint.constant = constraintVal * 4
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.52, animations: {
                        button.alpha = 0.05
                        btnConstraint.constant = constraintVal * 6
                        self.view.layoutIfNeeded()
                        UIView.animateWithDuration(0.52, animations: {
                            button.alpha = 0.07
                            btnConstraint.constant = constraintVal * 8
                            self.view.layoutIfNeeded()
                            UIView.animateWithDuration(0.52, animations: {
                                
                                button.alpha = 1
                                btnConstraint.constant = constraintVal * 10
                                self.view.layoutIfNeeded()
                                
                                
                                self.googleBtnAnimation(self.loginGoogleBtn, btnConstraint: self.googlebtnConstraints, constraintVal: 6.5)
                            }) { (animationFinished: Bool) in
                                
                                
                            }
                            
                        }) { (animationFinished: Bool) in
                            
                        }
                        
                    }) { (animationFinished: Bool) in
                        
                    }
                    
                }) { (animationFinished: Bool) in
                }
                
            }) { (animationFinished: Bool) in
            }
        }) { (animationFinished: Bool) in
            
        }
        
    }
    
    private func googleBtnAnimation(button: UIButton, btnConstraint: NSLayoutConstraint, constraintVal : CGFloat) {
        
        button.isHidden = false
        
        
        UIView.animateWithDuration(4.16, animations: {
            UIView.animateWithDuration(0.52, animations: {
                UIView.animateWithDuration(0.52, animations: {
                    UIView.animateWithDuration(0.52, animations: {
                        UIView.animateWithDuration(0.52, animations: {
                            button.alpha = 0.0
                            btnConstraint.constant = constraintVal * 2
                            self.view.layoutIfNeeded()
                            UIView.animateWithDuration(0.52, animations: {
                                button.alpha = 0.00
                                btnConstraint.constant = constraintVal * 4
                                self.view.layoutIfNeeded()
                                UIView.animateWithDuration(0.52, animations: {
                                    button.alpha = 0.00
                                    btnConstraint.constant = constraintVal * 6
                                    self.view.layoutIfNeeded()
                                    UIView.animateWithDuration(0.52, animations: {
                                        button.alpha = 0.08
                                        btnConstraint.constant = constraintVal * 8
                                        self.view.layoutIfNeeded()
                                        UIView.animateWithDuration(0.52, animations: {
                                            button.alpha = 0.5
                                            btnConstraint.constant = constraintVal * 10
                                            self.view.layoutIfNeeded()
                                        }) { (animationFinished: Bool) in
                                            
                                            
                                        }
                                        
                                    }) { (animationFinished: Bool) in
                                        self.skipBtn.isHidden = false
                                        self.skipBtnAnimation(self.skipBtn)
                                        UIView.animateWithDuration(0.52, animations: {
                                            button.alpha = 0.2
                                            UIView.animateWithDuration(0.52, animations: {
                                                button.alpha = 0.35
                                                UIView.animateWithDuration(0.52, animations: {
                                                    button.alpha = 0.55
                                                    UIView.animateWithDuration(0.52, animations: {
                                                        button.alpha = 0.75
                                                        UIView.animateWithDuration(0.52, animations: {
                                                            button.alpha = 9
                                                        }) { (animationFinished: Bool) in
                                                            button.alpha = 1
                                                            
                                                        }
                                                    }) { (animationFinished: Bool) in
                                                        
                                                        
                                                    }
                                                }) { (animationFinished: Bool) in
                                                    
                                                    
                                                }
                                            }) { (animationFinished: Bool) in
                                                
                                                
                                            }
                                            
                                        }) { (animationFinished: Bool) in
                                            
                                            
                                        }
                                    }
                                    
                                }) { (animationFinished: Bool) in
                                }
                                
                            }) { (animationFinished: Bool) in
                            }
                            
                        }) { (animationFinished: Bool) in
                        }
                    }) { (animationFinished: Bool) in
                    }
                }) { (animationFinished: Bool) in
                }
            }) { (animationFinished: Bool) in
            }
        }) { (animationFinished: Bool) in
        }
        
    }
    
    private func skipBtnAnimation(button: UIButton)  {
        
        button.isHidden = false
        UIView.animateWithDuration(2.6, animations: {
            
            UIView.animateWithDuration(0.52, animations: {
                button.alpha = 0.01
                
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(0.52, animations: {
                    button.alpha = 0.03
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.52, animations: {
                        button.alpha = 0.05
                        self.view.layoutIfNeeded()
                        UIView.animateWithDuration(0.52, animations: {
                            button.alpha = 0.07
                            self.view.layoutIfNeeded()
                            UIView.animateWithDuration(0.52, animations: {
                                button.alpha = 1
                                
                            }) { (animationFinished: Bool) in
                                
                                
                            }
                            
                        }) { (animationFinished: Bool) in
                            
                        }
                        
                    }) { (animationFinished: Bool) in
                        
                    }
                    
                }) { (animationFinished: Bool) in
                }
                
            }) { (animationFinished: Bool) in
            }
        }) { (animationFinished: Bool) in
            
        }
        
    }
     */
    
}
